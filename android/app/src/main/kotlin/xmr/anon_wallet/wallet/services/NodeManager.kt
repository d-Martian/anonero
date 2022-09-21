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

    fun isNodeConfigured(): Boolean {
        return isConfigured
    }

    suspend fun setNode() {
        withContext(Dispatchers.IO) {
            val serverUrl = AnonPreferences(AnonWallet.getAppContext()).serverUrl
            val serverPort = AnonPreferences(AnonWallet.getAppContext()).serverPort
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
                WalletEventsChannel.sendEvent(node.toHashMap().apply {
                    put("status", "connecting")
                })
                node.testRpcService()
                WalletManager.getInstance().setDaemon(node)
                WalletManager.getInstance().wallet.init(0)
                currentNode = node
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
        return currentNode;
    }

}
