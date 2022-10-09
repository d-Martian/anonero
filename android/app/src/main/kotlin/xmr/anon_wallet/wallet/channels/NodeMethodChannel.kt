package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.data.Node
import com.m2049r.xmrwallet.data.NodeInfo
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
        }
    }

    private fun testRPC(call: MethodCall, result: Result) {
        this.scope.launch {
            withContext(Dispatchers.IO) {
                val node = NodeInfo(/**/)
                node.setHost("testnet.community.rino.io")
                node.setRpcPort(28081)
            }
        }
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
                        NodeManager.setCurrentNode(node)
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

    companion object {
        const val CHANNEL_NAME = "node.channel"
        private const val TAG = "NodeMethodChannel"
    }
}