package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.data.Subaddress
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.TransactionInfo
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.utils.RestoreHeight
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.services.NodeManager
import java.io.File
import java.util.*
import kotlin.collections.HashMap


class WalletMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) :
    AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    init {
        listenWalletState()
    }

    private fun listenWalletState() {
        scope.launch {
            withContext(Dispatchers.IO) {
                WalletManager.getInstance().onManageCallBack {
                    val wallet = WalletManager.getInstance().wallet;
                    var lastBlockTime: Long = 0
                    wallet.setListener(WalletEventsChannel)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> createWallet(call, result)
            "generateSeed" -> generateSeed(call, result)
            "walletState" -> walletState(call, result)
            "openWallet" -> openWallet(call, result)
            "startSync" -> startSync(call, result)
        }
    }

    private fun startSync(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                val wallet = WalletManager.getInstance().wallet;
            }
        }
    }

    private fun openWallet(call: MethodCall, result: Result) {
        val walletPassword = call.argument<String>("password")
        val walletFile = File(AnonWallet.walletDir, "default")
        if (walletPassword == null) {
            result.error("INVALID_PASSWORD", "invalid password", null)
            return
        }
        scope.launch {
            withContext(Dispatchers.IO) {
                if (walletFile.exists()) {
                    try {
                        WalletEventsChannel.sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to true
                            )
                        )
                        val wallet =
                            WalletManager.getInstance().openWallet(walletFile.path, walletPassword)
                        result.success(wallet.walletToHashMap())
                        try {
                            NodeManager.setNode()
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                        WalletEventsChannel.initWalletRefresh()
                        if (wallet.isSynchronized) {
                            wallet.refreshHistory()
                        } else {
                            wallet.refresh()
                        }
                        WalletEventsChannel.sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to false
                            )
                        )
                        WalletEventsChannel.sendEvent(wallet.walletToHashMap())
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("WALLET_OPEN_ERROR", e.message, e.localizedMessage);
                    }
                }
            }
        }
    }

    private fun walletState(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.Default) {
                val exist =
                    WalletManager.getInstance().walletExists(File(AnonWallet.walletDir, "default"))
                if (exist) {
                    result.success(2)
                } else {
                    result.success(0)
                }
            }
        }
    }

    private fun createWallet(call: MethodCall, result: Result) {
        if (call.hasArgument("name") && call.hasArgument("password")) {
            val walletName = call.argument<String>("name")
            val password = call.argument<String>("password")
            val seedPhrase = call.argument<String?>("seedPhrase")
            val height = 1L
            if (walletName == null || walletName.isEmpty()) {
                return result.error(INVALID_ARG, "invalid name parameter", null);
            }
            if (password == null || password.isEmpty()) {
                return result.error(INVALID_ARG, "invalid password parameter", null);
            }
            var restoreHeight = 1L
            scope.launch {
                withContext(Dispatchers.IO) {
                    val cacheFile = File(AnonWallet.walletDir, walletName)
                    val keysFile = File(AnonWallet.walletDir, "$walletName.keys")
                    val addressFile = File(AnonWallet.walletDir, "$walletName.address.txt")
                    //TODO
                    if (addressFile.exists()) {
                        addressFile.delete()
                    }
                    if (keysFile.exists()) {
                        keysFile.delete()
                    }
                    if (cacheFile.exists()) {
                        cacheFile.delete()
                    }
                    //TODO
//                    if (cacheFile.exists() || keysFile.exists() || addressFile.exists()) {
//                        Timber.e("Some wallet files already exist for %s", cacheFile.absolutePath)
//                        result.error(WALLET_EXIST, "Some wallet files already exist for ${cacheFile.absolutePath}", null)
//                        return@withContext
//                    }
                    val newWalletFile = File(AnonWallet.walletDir, walletName)
                    val default = "English"
                    if (AnonWallet.getNetworkType() == NetworkType.NetworkType_Mainnet) {
                        if (NodeManager.getNode() != null && NodeManager.getNode()?.getHeight() != null) {
                            restoreHeight = NodeManager.getNode()?.getHeight()!!
                        }
                        val restoreDate = Calendar.getInstance()
                        restoreDate.add(Calendar.DAY_OF_MONTH, -4)
                        RestoreHeight.getInstance().getHeight(restoreDate.time)
                    } else {
                        restoreHeight = NodeManager.getNode()?.getHeight() ?: 1L
                    }
                    val wallet = WalletManager.getInstance()
                        .createWallet(newWalletFile, password, default, restoreHeight)
                    if (wallet.status.isOk) {
                        wallet.refreshHistory()
                        val map = wallet.walletToHashMap()
                        map["seed"] = wallet.getSeed(seedPhrase ?: "")
                        wallet.store()
                        result.success(map)
                        WalletEventsChannel.sendEvent(map.apply {
                            put("EVENT_TYPE", "WALLET")
                        })
                        if (!NodeManager.isNodeConfigured()) {
                            NodeManager.setNode()
                            if (!wallet.isSynchronized) {
                                WalletEventsChannel.initWalletRefresh()
                            }
                        }
                    } else {
                        result.error(wallet.status.status.name, wallet.status.errorString, null)
                    }
                }
            }.invokeOnCompletion {
                if (it != null) {
                    it.printStackTrace()
                    result.error(ERRORS, it.message, it);
                }
            }
        }
    }

    ///TODO: Restore
    private fun restoreWallet(call: MethodCall, result: Result) {

    }

    private fun generateSeed(call: MethodCall, result: Result) {
        if (call.hasArgument("seedPassPhrase") && call.hasArgument("password")) {
            scope.launch {
                val seedPassPhrase = call.argument<String>("seedPassPhrase")
                val password = call.argument<String>("password")
                val walletFile = File(AnonWallet.walletDir, "default")
                val wallet = WalletManager.getInstance().openWallet(walletFile.path, password)
                if (wallet.status.isOk) {
                    val map = wallet.walletToHashMap();
                    map["seed"] = wallet.getSeed(seedPassPhrase)
                    wallet.close()
                    result.success(map)
                }
            }
        }
    }

    companion object {
        private const val TAG = "WalletMethodChannel"
        const val CHANNEL_NAME = "wallet.channel"
        const val WALLET_EVENT_CHANNEL = "wallet.events"
    }


}

fun TransactionInfo.toHashMap(): HashMap<String, Any> {
    return hashMapOf(
        "address" to this.address,
        "addressIndex" to this.addressIndex,
        "amount" to this.amount,
        "accountIndex" to this.accountIndex,
        "blockheight" to this.blockheight,
        "confirmations" to this.confirmations,
        "isPending" to this.isPending,
        "timestamp" to this.timestamp,
        "isConfirmed" to this.isConfirmed,
        "paymentId" to this.paymentId,
        "hash" to this.hash,
        "notes" to this.notes,
        "displayLabel" to this.displayLabel,
        "subaddressLabel" to this.subaddressLabel,
        "fee" to this.fee,
    )
}

fun Wallet.getLastUsedAccount(): Int {
    var lastUsedAccount = 0
    for (info in this.history.all) {
        if (info.accountIndex > lastUsedAccount) lastUsedAccount = info.accountIndex
    }
    return lastUsedAccount
}

fun Wallet.getLatestSubaddress(): Subaddress? {
    var lastUsedSubaddress = 1
    for (info in this.history.all) {
        if (info.addressIndex > lastUsedSubaddress) lastUsedSubaddress = info.addressIndex
    }
    lastUsedSubaddress++
    return this.getSubaddressObject(lastUsedSubaddress)
}

fun Subaddress.toHashMap(): HashMap<String, Any> {
    return hashMapOf<String, Any>(
        "address" to (this.address ?: ""),
        "addressIndex" to this.addressIndex,
        "addressIndex" to this.addressIndex,
        "accountIndex" to this.accountIndex,
        "label" to (this.label ?: ""),
        "squashedAddress" to this.squashedAddress,
    );
}

fun Wallet.walletToHashMap(): HashMap<String, Any> {
    val nextAddress =  if(this.getLatestSubaddress() != null) this.getLatestSubaddress()?.toHashMap()!! else   hashMapOf<String,String>()
    return  hashMapOf(
        "name" to this.name,
        "address" to this.address,
        "secretViewKey" to this.secretViewKey,
        "balance" to this.balance,
        "currentAddress" to nextAddress,
        "isSynchronized" to this.isSynchronized,
        "blockChainHeight" to this.blockChainHeight,
        "numSubaddresses" to this.numSubaddresses,
        "seedLanguage" to this.seedLanguage,
        "restoreHeight" to this.restoreHeight,
        "transactions" to this.history.all.map { it.toHashMap() }.reversed().toList(),
        "EVENT_TYPE" to "WALLET",
    )
}
