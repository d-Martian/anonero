package xmr.anon_wallet.wallet.services

import com.m2049r.xmrwallet.data.NodeInfo

import com.m2049r.xmrwallet.model.WalletManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.channels.WalletEventsChannel
import xmr.anon_wallet.wallet.utils.AnonPreferences


object NodeManager {

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
                WalletEventsChannel.sendEvent(node.toHashMap().apply {
                    put("status", "connecting")
                })
                currentNode = node
                WalletManager.getInstance().setDaemon(node)
                isConfigured = true
                WalletEventsChannel.sendEvent(node.toHashMap().apply {
                    put("status", "connected")
                })
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

}
