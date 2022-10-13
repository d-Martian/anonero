package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.utils.RestoreHeight
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import xmr.anon_wallet.wallet.utils.AnonPreferences
import java.io.File
import java.util.*


class WalletMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    init {
        listenWalletState()
    }

    init {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    NodeManager.setNode()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
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
                WalletManager.getInstance().wallet;
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
                        wallet.refreshHistory()
                        NodeManager.getNode()?.let {
                            if(it.isSuccessful){
                                WalletEventsChannel.initWalletRefresh()
                                if (wallet.isSynchronized) {
                                    wallet.startRefresh()
                                } else {
                                    wallet.refresh()
                                    wallet.refreshHistory()
                                }
                                WalletManager.getInstance().wallet.init(0)
                            }
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
                    WalletEventsChannel.sendEvent(
                        hashMapOf(
                            "EVENT_TYPE" to "OPEN_WALLET",
                            "state" to true
                        )
                    )
                    val wallet = WalletManager.getInstance()
                        .createWallet(newWalletFile, password, default, restoreHeight)
                    WalletEventsChannel.initWalletRefresh()
                    val map = wallet.walletToHashMap()
                    map["seed"] = wallet.getSeed(seedPhrase ?: "")
                    wallet.store()
                    result.success(map)
                    if(AnonPreferences(AnonWallet.getAppContext()).serverUrl != null){
                        NodeManager.setNode()
                    }
                    if (wallet.status.isOk) {
                        wallet.refresh()
                        WalletManager.getInstance().wallet.init(0)
                        wallet.refreshHistory()
                        WalletEventsChannel.sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to false
                            )
                        )
                    } else {
                        WalletEventsChannel.sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to false
                            )
                        )
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