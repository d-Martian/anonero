package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet
import java.io.File


class WalletMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> createWallet(call, result)
            "generateSeed" -> generateSeed(call, result)
        }
    }

    private fun createWallet(call: MethodCall, result: Result) {
        if (call.hasArgument("name") && call.hasArgument("password")) {
            val walletName = call.argument<String>("name")
            val password = call.argument<String>("password")
            val seedPhrase = call.argument<String?>("seedPhrase")
            if (walletName == null || walletName.isEmpty()) {
                return result.error(INVALID_ARG, "invalid name parameter", null);
            }
            if (password == null || password.isEmpty()) {
                return result.error(INVALID_ARG, "invalid password parameter", null);
            }
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
                    val wallet = WalletManager.getInstance().createWallet(newWalletFile, password, default, -1)
                    if (wallet.status.isOk) {
                        AnonWallet.setWallet(wallet)
                        val map = hashMapOf(
                            "name" to wallet.name,
                            "address" to wallet.address,
                            "secretViewKey" to wallet.secretViewKey,
                            "seedLanguage" to wallet.seedLanguage,
                            "restoreHeight" to wallet.restoreHeight,
                            "seed" to wallet.getSeed(seedPhrase ?: "")
                        )
                        result.success(map)
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
                    val map = hashMapOf(
                        "name" to wallet.name,
                        "address" to wallet.address,
                        "secretViewKey" to wallet.secretViewKey,
                        "seedLanguage" to wallet.seedLanguage,
                        "restoreHeight" to wallet.restoreHeight,
                        "seed" to wallet.getSeed(seedPassPhrase)
                    )
                    wallet.close()
                    result.success(map)
                }
            }
        }
    }


    companion object {
        private const val TAG = "WalletMethodChannel"
        const val CHANNEL_NAME = "wallet.channel"
    }
}