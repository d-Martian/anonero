package xmr.anon_wallet.wallet.channels

import android.util.Log
import android.util.Patterns
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
            "getNodeFromPrefs" -> getNodeFromPrefs(call, result)
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

    private fun getNodeFromPrefs(call: MethodCall, result: Result) {
        val preferences = AnonPreferences(AnonWallet.getAppContext());
        if(preferences.serverUrl.isNullOrEmpty() || preferences.serverPort == null){
            result.error("0","No node found",null);
            return;
        }
        val hashMap = hashMapOf<String, Any>()
        hashMap["host"] = preferences.serverUrl ?: "";
        preferences.serverPort?.let {
            hashMap["rpcPort"] = it;
        }
        hashMap["username"] = preferences.serverUserName ?: ""
        hashMap["password"] = preferences.serverPassword ?: ""
        hashMap["EVENT_TYPE"] = "NODE"
        hashMap["isActive"] =  false
        return result.success(hashMap)
    }

    private fun setProxy(call: MethodCall, result: Result) {
        val proxyServer = call.argument<String?>("proxyServer")
        val proxyPort = call.argument<String?>("proxyPort")
        val preferences = AnonPreferences(AnonWallet.getAppContext());
        this.scope.launch {
            withContext(Dispatchers.IO){
              try {
                  if (!proxyServer.isNullOrEmpty() && !proxyPort.isNullOrEmpty()) {
                      if (!Patterns.IP_ADDRESS.matcher(proxyServer).matches()) {
                          result.error("1", "Invalid server IP", "")
                          return@withContext
                      }
                      val port = try {
                          proxyPort.toInt()
                      } catch (e: Exception) {
                          -1
                      }
                      if (1 > port || port > 65535) {
                          result.error("1", "Invalid port", "")
                          return@withContext;
                      }
                      preferences.proxyServer = proxyServer
                      preferences.proxyPort = proxyPort
                      WalletManager.getInstance()?.setProxy("${proxyServer}:${proxyPort}")
                      WalletManager.getInstance().wallet?.setProxy("${proxyServer}:${proxyPort}")
                  }else if (proxyServer.isNullOrEmpty() || proxyPort.isNullOrEmpty()) {
                      preferences.proxyServer = proxyServer
                      preferences.proxyPort = proxyPort
                      WalletManager.getInstance()?.wallet?.setProxy("")
                      WalletManager.getInstance()?.setProxy("")
                  }
                  result.success(true)
              }catch (e:Exception){
                  result.error("0",e.message,"")
                  throw  CancellationException(e.message)
              }
            }
        }
    }

    private fun setNode(call: MethodCall, result: Result) {
        val port = call.argument<Int?>("port")
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
        if(host.trim().isEmpty()){
            result.error("0","Invalid hostname","");
            return
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
                    if(host.contains(".onion")){
                        if(AnonPreferences(AnonWallet.getAppContext()).proxyServer.isNullOrEmpty()){
                            WalletEventsChannel.sendEvent(node.toHashMap().apply {
                                put("status", "not-connected")
                            })
                            result.error("0","Please set tor proxy to connect onion urls","");
                            return@withContext;
                        }
                    }
                    val testSuccess = node.testRpcService()

                    if (testSuccess == true) {
                        AnonPreferences(AnonWallet.getAppContext()).serverUrl = host
                        AnonPreferences(AnonWallet.getAppContext()).serverPort = port
                        if (!node.username.isNullOrEmpty()) {
                            AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.username
                        }
                        if (!node.password.isNullOrEmpty()) {
                            AnonPreferences(AnonWallet.getAppContext()).serverUserName = node.password
                        }
                        WalletManager.getInstance().setDaemon(node)
                        NodeManager.setCurrentActiveNode(node)
                        WalletEventsChannel.sendEvent(node.toHashMap().apply {
                            put("status", "connected")
                        })
                        result.success(node.toHashMap())
                    } else {
                        WalletEventsChannel.sendEvent(node.toHashMap().apply {
                            put("status", "disconnected")
                            put("connection_error", "Failed to connect to remote node")
                        })
                        result.error("2", "Failed to connect to remote node", "")
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
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