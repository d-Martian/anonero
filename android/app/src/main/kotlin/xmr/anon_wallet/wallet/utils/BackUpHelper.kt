package xmr.anon_wallet.wallet.utils

import com.m2049r.xmrwallet.model.WalletManager
import org.json.JSONObject
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.services.NodeManager

object BackUpHelper {
    private const val BACKUP_VERSION = "1.0"

    fun createBackUp(seedPassphrase: String): String {
        val wallet = WalletManager.getInstance().wallet
        val walletPayload = JSONObject()
            .apply {
                put("address", wallet.address)
                put("seed", wallet.getSeed(seedPassphrase))
                put("restoreHeight", wallet.restoreHeight)
                put("balanceAll", wallet.balanceAll)
                put("numSubaddresses", wallet.numSubaddresses)
                put("numAccounts", wallet.numAccounts)
                put("isWatchOnly", wallet.isWatchOnly)
                put("isSynchronized", wallet.isSynchronized)
            }
        val nodePayload = JSONObject()
            .apply {
                NodeManager.getNode()?.let { nodeInfo ->
                    put("host", nodeInfo.host)
                    put("password", nodeInfo.password)
                    put("username", nodeInfo.username)
                    put("rpcPort", nodeInfo.rpcPort)
                    put("networkType", nodeInfo.networkType)
                    put("isOnion", nodeInfo.isOnion)
                }
            }

        val metaPayload = JSONObject().apply {
            put("timestamp", System.currentTimeMillis())
            put("network", AnonWallet.getNetworkType().toString())
        }
        val backUpPayload = JSONObject().apply {
            put("node", nodePayload)
            put("wallet", walletPayload)
            put("meta", metaPayload)
        }

        val encryptedPayload = EncryptUtil.encrypt(seedPassphrase, backUpPayload.toString())

        return JSONObject().apply {
            put("version", BACKUP_VERSION)
            put("backup", encryptedPayload)
        }.toString()
    }

}