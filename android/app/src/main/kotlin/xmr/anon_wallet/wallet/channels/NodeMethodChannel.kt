package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.data.NodeInfo
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.services.NodeManager
import xmr.anon_wallet.wallet.utils.AnonPreferences

class NodeMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) :
    AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setNode" -> setNode(call, result)
            "setProxy" -> setProxy(call, result)
            "getProxy" -> getProxy(call, result)
            "getAllNodes" -> getAllNodes(result)
            "addNewNode" -> addNewNode(call, result)
            "removeNode" -> removeNode(call, result)
            "setCurrentNode" -> setCurrentNode(call, result)
            "testRpc" -> testRpc(call, result)
        }
    }

    private fun getProxy(call: MethodCall, result: Result) {
        val preferences = AnonPreferences(AnonWallet.getAppContext());
        return result.success(
            hashMapOf(
                "proxyServer" to preferences.proxyServer,
                "proxyPort" to preferences.proxyPort,
            )
        )
    }

    private fun setProxy(call: MethodCall, result: Result) {
        val proxyServer = call.argument<String?>("proxyServer")
        val proxyPort = call.argument<String?>("proxyPort")
        val preferences = AnonPreferences(AnonWallet.getAppContext());

        val regex = Regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}\$")
        if (!proxyServer.isNullOrEmpty() && !proxyPort.isNullOrEmpty()) {
            if (!regex.matches(proxyServer)) {
                result.error("1", "Invalid server IP", "")
                return;
            }
            val port = try {
                proxyPort.toInt()
            } catch (e: Exception) {
                -1
            }
            if (1 > port || port > 65535) {
                result.error("1", "Invalid port", "")
                return;
            }
            preferences.proxyServer = proxyServer
            preferences.proxyPort = proxyPort
            WalletManager.getInstance()?.setProxy("${proxyServer}:${proxyPort}")
            WalletManager.getInstance().wallet?.setProxy("${proxyServer}:${proxyPort}")
        }
        if (proxyServer.isNullOrEmpty() || proxyPort.isNullOrEmpty()) {
            preferences.proxyServer = proxyServer
            preferences.proxyPort = proxyPort
            WalletManager.getInstance()?.wallet?.setProxy("")
            WalletManager.getInstance()?.setProxy("")
        }
        result.success(true)
    }

    private fun setNode(call: MethodCall, result: Result) {
        val port = call.argument<Int>("port")
        var host = call.argument<String>("host")
        val userName = call.argument<String?>("username")
        val password = call.argument<String?>("password")
        if (port == null || host == null) {
            return result.error("1", "Invalid params", "")
        }
        if (host.lowercase().startsWith("http://")) {
            host = host.replace("http://", "")
        }
        if (host.lowercase().startsWith("https://")) {
            host = host.replace("https://", "")
        }
        this.scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val node = NodeInfo(/**/)
                    node.host = host
                    node.rpcPort = port
                    WalletEventsChannel.sendEvent(node.toHashMap().apply {
                        put("status", "connecting")
                    })
                    userName?.let {
                        node.username = it
                    }
                    password?.let {
                        node.password = it
                    }
                    val testSuccess = node.testRpcService()
                    if (testSuccess == true) {
                        WalletEventsChannel.sendEvent(node.toHashMap().apply {
                            put("status", "connected")
                        })
                        AnonPreferences(AnonWallet.getAppContext()).serverUrl = host
                        AnonPreferences(AnonWallet.getAppContext()).serverPort = port
                        if (!node.username.isNullOrEmpty()) {
                            AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.username
                        }
                        if (!node.password.isNullOrEmpty()) {
                            AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.password
                        }
                        NodeManager.setCurrentActiveNode(node)
                        result.success(node.toHashMap())
                    } else {
                        WalletEventsChannel.sendEvent(node.toHashMap().apply {
                            put("status", "disconnected")
                            put("connection_error", "Failed to connect to remote node")
                        })
                        result.error("2", "Failed to connect to remote node", "")
                    }
                } catch (e: Exception) {
                    WalletEventsChannel.sendEvent(
                        hashMapOf(
                            "EVENT_TYPE" to "NODE",
                            "status" to "disconnected",
                            "connection_error" to "Failed to connect to remote node"
                        )
                    )
                    e.printStackTrace()
                    result.error("2", "${e.message}", e.cause)
                    throw CancellationException(e.message)
                }
            }
        }
    }

    private fun addNewNode(call: MethodCall, result: Result) {
        val port = call.argument<Int>("port")
        var host = call.argument<String>("host")
        val userName = call.argument<String?>("username")
        val password = call.argument<String?>("password")
        if (port == null || host == null) {
            return result.error("1", "Invalid params", "")
        }
        if (host.lowercase().startsWith("http://")) {
            host = host.replace("http://", "")
        }
        if (host.lowercase().startsWith("https://")) {
            host = host.replace("https://", "")
        }

        this.scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val findResult = NodeManager.getNodes().find {
                        (it.host).lowercase() == host.lowercase() && (it.rpcPort == port)
                    }
                    if (findResult != null) {
                        result.error("1", "Node already exist", "")
                        return@withContext
                    }
                    val node = NodeInfo(/**/)
                    node.host = host
                    node.rpcPort = port
                    userName?.let {
                        node.username = it
                    }
                    password?.let {
                        node.password = it
                    }
                    val testSuccess = node.testRpcService()
                    if (testSuccess == true) {
                        result.success(node.toHashMap())
                        NodeManager.addNode(node)
                    } else {
                        result.error("2", "Failed to connect to remote node", "")
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error("2", "${e.message}", e.cause)
                    throw CancellationException(e.message)
                }
            }
        }
    }



    private fun removeNode(call: MethodCall, result: Result) {
        val port = call.argument<Int>("port")
        var host = call.argument<String>("host")
        val userName = call.argument<String?>("username")
        val password = call.argument<String?>("password")
        if (port == null || host == null) {
            return result.error("1", "Invalid params", "")
        }
        if (host.lowercase().startsWith("http://")) {
            host = host.replace("http://", "")
        }
        if (host.lowercase().startsWith("https://")) {
            host = host.replace("https://", "")
        }
        scope.launch {
            withContext(Dispatchers.IO){
                try {
                    NodeManager.removeNode(host,port,userName,password)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                result.success(true);
            }
        }
    }



    private fun getAllNodes(result: Result) {
        scope.launch {
            val server = AnonPreferences(AnonWallet.getAppContext()).serverUrl
            val port = AnonPreferences(AnonWallet.getAppContext()).serverPort
            val nodesList = arrayListOf<HashMap<String, Any>>()
            NodeManager.getNodes().let { items->
                items.forEach {
                    val nodeHashMap = it.toHashMap()
                    nodeHashMap["isActive"] = server == it.host && port == it.rpcPort;
                    nodesList.add(nodeHashMap)
                }
            }
            withContext(Dispatchers.IO) {
                result.success(nodesList)
            }
        }
    }

    private fun testRpc(call: MethodCall, result: Result) {
        val port = call.argument<Int>("port")
        var host = call.argument<String>("host")
        val userName = call.argument<String?>("username")
        val password = call.argument<String?>("password")
        if (port == null || host == null) {
            return result.error("1", "Invalid params", "")
        }
        if (host.lowercase().startsWith("http://")) {
            host = host.replace("http://", "")
        }
        if (host.lowercase().startsWith("https://")) {
            host = host.replace("https://", "")
        }
        scope.launch {
            withContext(Dispatchers.IO) {
                val node = NodeInfo(/**/)
                node.host = host
                node.rpcPort = port
                userName?.let {
                    node.username = it
                }
                password?.let {
                    node.password = it
                }
                try {
                    val success = node.testRpcService()
                    Log.i(TAG, "testRpc: ${node.toHashMap()}")
                    if (success == true) {
                        NodeManager.updateExistingNode(node)
                    }
                    result.success(node.toHashMap());
                } catch (e: Exception) {
                    result.error("1", "${e.message}", "")
                }
            }
        }
    }

    private fun setCurrentNode(call: MethodCall, result: Result) {
        val port = call.argument<Int>("port")
        var host = call.argument<String>("host")
        val userName = call.argument<String?>("username")
        val password = call.argument<String?>("password")
        if (port == null || host == null) {
            return result.error("1", "Invalid params", "")
        }
        if (host.lowercase().startsWith("http://")) {
            host = host.replace("http://", "")
        }
        if (host.lowercase().startsWith("https://")) {
            host = host.replace("https://", "")
        }
        scope.launch {
            withContext(Dispatchers.IO){
                try {
                    val node = NodeInfo(/**/)
                    node.host = host
                    node.rpcPort = port
                    userName?.let {
                        node.username = it
                    }
                    password?.let {
                        node.password = it
                    }
                    AnonPreferences(AnonWallet.getAppContext()).serverUrl = host
                    AnonPreferences(AnonWallet.getAppContext()).serverPort = port
                    if (!node.username.isNullOrEmpty()) {
                        AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.username
                    }
                    if (!node.password.isNullOrEmpty()) {
                        AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.password
                    }

                    NodeManager.setCurrentActiveNode(node)
                    WalletManager.getInstance().setDaemon(node)
                    WalletManager.getInstance().wallet?.let {
                        it.refresh()
                        it.startRefresh()
                    }
                    result.success(node.toHashMap())
                } catch (e: Exception) {
                    result.error("1","${e.message}",e)
                }
            }
        }
    }

    companion object {
        const val CHANNEL_NAME = "node.channel"
        private const val TAG = "NodeMethodChannel"
    }
}