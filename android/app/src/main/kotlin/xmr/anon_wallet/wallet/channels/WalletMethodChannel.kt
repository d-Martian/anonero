package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.util.KeyStoreHelper
import com.m2049r.xmrwallet.utils.RestoreHeight
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.channels.WalletEventsChannel.sendEvent
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import xmr.anon_wallet.wallet.utils.AnonPreferences
import java.io.File
import java.net.SocketException
import java.util.*
import java.util.concurrent.Executors


class WalletMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    init {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    NodeManager.setNode()
                } catch (socket: SocketException) {
                    Log.i(TAG, "SocketException :${socket.message} ")
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun runWalletHandler() {
        val walletContext = Executors.newFixedThreadPool(12).asCoroutineDispatcher()
        scope.launch {
            withContext(walletContext) {
                WalletManager.getInstance().onManageCallBack {
                    val wallet = WalletManager.getInstance().wallet
                    wallet.setListener(WalletEventsChannel)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> createWallet(call, result)
            "walletState" -> walletState(call, result)
            "openWallet" -> openWallet(call, result)
            "viewWalletInfo" -> viewWalletInfo(call, result)
            "rescan" -> rescan(call, result)
            "refresh" -> refresh(call, result)
            "startSync" -> startSync(call, result)
        }
    }

    private fun viewWalletInfo(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val seedPassphrase = call.argument<String?>("seedPassphrase")
                    val hash = AnonPreferences(AnonWallet.getAppContext()).passPhraseHash
                    val hashedPass = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), seedPassphrase)
                    if (hashedPass == hash) {
                        val wallet = WalletManager.getInstance().wallet
                        result.success(
                            hashMapOf(
                                "address" to wallet.address,
                                "secretViewKey" to wallet.secretSpendKey,
                                "seed" to wallet.getSeed(seedPassphrase),
                                "spendKey" to wallet.secretSpendKey
                            )
                        )
                    } else {
                        result.error("1", "Invalid passphrase", "")
                    }
                } catch (e: Exception) {
                    result.error("2", e.message, "")
                    e.printStackTrace()
                }
            }
        }
    }

    private fun refresh(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                val wallet = WalletManager.getInstance().wallet
                if (wallet != null) {
                    try {
                        wallet.startRefresh()
                        wallet.refreshHistory()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("1", "error", "")
                        sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "NODE",
                                "status" to "disconnected",
                                "connection_error" to "${e.message}"
                            )
                        )
                        throw  CancellationException()
                    }
                } else {
                    result.success(false)
                }
            }
        }
    }

    private fun rescan(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                WalletManager.getInstance().wallet?.let {
                    try {
                        result.success(true)
                        it.rescanBlockchainAsync()
                        it.refreshHistory()
                    } catch (e: Exception) {
                        result.success(false)
                        sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "NODE",
                                "status" to "disconnected",
                                "connection_error" to "Error ${e.message}"
                            )
                        )
                    }
                }
            }
        }
    }

    private fun startSync(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                WalletManager.getInstance().wallet
            }
        }
    }

    private fun openWallet(call: MethodCall, result: Result) {
        val walletPassword = call.argument<String>("password")
        val walletFileName = "default"
        val walletFile = File(AnonWallet.walletDir, walletFileName)
        if (walletPassword == null) {
            result.error("INVALID_PASSWORD", "invalid pin", null)
            return
        }
        scope.launch {
            withContext(Dispatchers.IO) {
                if (walletFile.exists()) {
                    try {
                        sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to true
                            )
                        )
                        // check if we need connected hardware
                        val checkPassword = AnonWallet.getWalletPassword(walletFileName, walletPassword) != null
                        if (!checkPassword) {
                            result.error("1", "Invalid pin", "invalid pin")
                            return@withContext
                        }
                        runWalletHandler()
                        val wallet = WalletManager.getInstance().openWallet(walletFile.path, walletPassword)
                        wallet.refreshHistory()
                        wallet.startRefresh()
                        result.success(wallet.walletToHashMap())
                        NodeManager.getNode()?.let {
                            wallet.init(0)
                        }
                        sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to false
                            )
                        )
                        sendEvent(wallet.walletToHashMap())
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("WALLET_OPEN_ERROR", e.message, e.localizedMessage)
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
            val walletPin = call.argument<String>("password")
            val seedPhrase = call.argument<String?>("seedPhrase")
            if (walletName == null || walletName.isEmpty()) {
                return result.error(INVALID_ARG, "invalid name parameter", null)
            }
            if (walletPin == null || walletPin.isEmpty()) {
                return result.error(INVALID_ARG, "invalid password parameter", null)
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
                    runWalletHandler()
                    //Close if wallet is already open
                    WalletManager.getInstance().wallet?.close()
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
                    sendEvent(
                        hashMapOf(
                            "EVENT_TYPE" to "OPEN_WALLET",
                            "state" to true
                        )
                    )
                    val wallet = WalletManager.getInstance()
                        .createWallet(newWalletFile, walletPin, default, restoreHeight)
                    AnonPreferences(context = AnonWallet.getAppContext()).passPhraseHash = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), seedPhrase)
                    val map = wallet.walletToHashMap()
                    map["seed"] = wallet.getSeed(seedPhrase ?: "")
                    wallet.store()
                    result.success(map)
                    if (AnonPreferences(AnonWallet.getAppContext()).serverUrl != null) {
                        NodeManager.setNode()
                    }
                    WalletEventsChannel.initWalletRefresh()
                    if (wallet.status.isOk) {
                        wallet.refresh()
                        sendEvent(wallet.walletToHashMap())

                        WalletManager.getInstance().wallet.init(0)
                        wallet.refreshHistory()
                        sendEvent(
                            hashMapOf(
                                "EVENT_TYPE" to "OPEN_WALLET",
                                "state" to false
                            )
                        )
                    } else {
                        sendEvent(
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
                    result.error(ERRORS, it.message, it)
                }
            }
        }
    }

    ///TODO: Restore
    private fun restoreWallet(call: MethodCall, result: Result) {

    }

    companion object {
        private const val TAG = "WalletMethodChannel"
        const val CHANNEL_NAME = "wallet.channel"
        const val WALLET_EVENT_CHANNEL = "wallet.events"
    }

}