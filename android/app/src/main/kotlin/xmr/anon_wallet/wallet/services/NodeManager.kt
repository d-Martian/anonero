package xmr.anon_wallet.wallet.services

import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.m2049r.xmrwallet.data.NodeInfo
import com.m2049r.xmrwallet.model.WalletManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.AnonWallet.proxyPort
import xmr.anon_wallet.wallet.AnonWallet.proxyServer
import xmr.anon_wallet.wallet.channels.WalletEventsChannel
import xmr.anon_wallet.wallet.services.NodeManager.storeNodesList
import xmr.anon_wallet.wallet.utils.AnonPreferences


object NodeManager {

    private val gson = Gson()
    private var isConfigured = false
    private var currentNode: NodeInfo? = null
    private var nodes = arrayListOf<NodeInfo>()

    fun isNodeConfigured(): Boolean {
        return isConfigured
    }

    suspend fun setNode() {
        withContext(Dispatchers.IO) {
            val preferences = AnonPreferences(AnonWallet.getAppContext())
            val serverUrl = preferences.serverUrl
            val serverPort = preferences.serverPort
            if (serverUrl == null || serverUrl.isEmpty() || serverPort == null) {
                isConfigured = false
                WalletEventsChannel.sendEvent(
                    hashMapOf(
                        "EVENT_TYPE" to "NODE",
                        "status" to "disconnected",
                        "connection_error" to ""
                    )
                )
                return@withContext
            }
            try {
                val node = NodeInfo(/**/)
                node.host = serverUrl
                node.rpcPort = serverPort
                preferences.serverUserName?.let { username ->
                    preferences.serverPassword?.let {
                        node.username = username
                        node.password = it
                    }
                }

                val proxyServer = preferences.proxyServer;
                val proxyPort = preferences.proxyPort;
                if (!proxyPort.isNullOrEmpty() && !proxyServer.isNullOrEmpty()) {
                    WalletManager.getInstance()?.setProxy("${proxyServer}:${proxyPort}")
                    WalletManager.getInstance()?.wallet?.setProxy("${proxyServer}:${proxyPort}")
                }
                WalletEventsChannel.sendEvent(node.toHashMap().apply {
                    put("status", "connecting")
                })
                currentNode = node
                if (testRPC()) {
                    WalletManager.getInstance().setDaemon(node)
                    isConfigured = true
                    WalletEventsChannel.sendEvent(node.toHashMap().apply {
                        put("status", "connected")
                    })
                }
            } catch (e: Exception) {
                WalletEventsChannel.sendEvent(
                    hashMapOf(
                        "EVENT_TYPE" to "NODE",
                        "status" to "disconnected",
                        "connection_error" to "Error ${e.message}"
                    )
                )
                e.printStackTrace()
            }
        }
    }

    fun getNode(): NodeInfo? {
        return currentNode
    }

    fun setCurrentActiveNode(node: NodeInfo) {
        currentNode = node
    }

    suspend fun testRPC(): Boolean {
        return withContext(Dispatchers.IO) {
            if (currentNode != null) {
                try {
                    if (currentNode!!.testRpcService() == true) {
                        val node = currentNode!!.toHashMap()
                        node["status"] = "connected"
                        node["connection_error"] = ""
                        WalletEventsChannel.sendEvent(node)
                        return@withContext true
                    } else {
                        val node = currentNode!!.toHashMap()
                        node["status"] = "disconnected"
                        node["connection_error"] = "Unable to reach node"
                        WalletEventsChannel.sendEvent(node)
                        return@withContext false
                    }
                } catch (e: Exception) {
                    val node = currentNode!!.toHashMap()
                    node["status"] = "disconnected"
                    node["connection_error"] = "$e"
                    WalletEventsChannel.sendEvent(node)
                    return@withContext false
                }
            } else {
                hashMapOf(
                    "EVENT_TYPE" to "NODE",
                    "status" to "disconnected",
                    "connection_error" to "Node not connected"
                )
                return@withContext false
            }
        }
    }

    suspend fun storeNodesList() {
        withContext(Dispatchers.IO) {
            val nodeListFile = AnonWallet.nodesFile
            if (!nodeListFile.exists()) {
                nodeListFile.createNewFile()
            }
            val jsonObj: List<JSONObject> = nodes.map { JSONObject(it.toHashMap().toMap()) }
            nodeListFile.writeText(JSONArray(jsonObj).toString())
        }
    }

    private suspend fun readNodes() {
        nodes = arrayListOf()
        withContext(Dispatchers.IO) {
            val nodeListFile = AnonWallet.nodesFile
            if (!nodeListFile.exists()) {
                nodeListFile.createNewFile()
            }
            val values = nodeListFile.readText()
            if (values.isNotEmpty()) {
                val jsonArray = JSONArray(values)
                nodes = arrayListOf();
                repeat(jsonArray.length()) {
                    val item = jsonArray.getJSONObject(it)
                    val nodeItem: NodeInfo = gson.fromJson(item.toString(), object : TypeToken<NodeInfo>() {}.type)
                    nodes.add(nodeItem)
                }
            } else {
                nodes = arrayListOf();
            }
        }
    }

    suspend fun getNodes(): ArrayList<NodeInfo> {
        return withContext(Dispatchers.IO) {
            try {
                readNodes()
                nodes.find { it.host == currentNode?.host && it.rpcPort == currentNode?.rpcPort }
                    .let {
                        if (it == null && currentNode != null) {
                            nodes.add(currentNode!!)
                        }
                    }
                nodes = ArrayList(
                    nodes.distinctBy { it.toString() }
                )
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return@withContext nodes
        }
    }

    suspend fun addNode(node: NodeInfo) {
        nodes.add(node)
        storeNodesList()
    }

    suspend fun updateExistingNode(node: NodeInfo) {
        val newList = arrayListOf<NodeInfo>()
        nodes.forEach {
            if (node.host == it.host && node.rpcPort == it.rpcPort) {
                newList.add(node)
            } else {
                newList.add(it)
            }
        }
        nodes = newList
        storeNodesList()
    }

    suspend fun removeNode(host: String, port: Int, userName: String?, password: String?) {
        nodes = ArrayList(
            nodes.filter {
                it.host != host &&
                        it.rpcPort != port
            }.toList()
        )
        storeNodesList()
    }

}
