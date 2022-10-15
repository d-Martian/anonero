package xmr.anon_wallet.wallet

import android.util.Log
import androidx.annotation.NonNull
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.channels.*
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import xmr.anon_wallet.wallet.utils.AnonPreferences
import java.net.SocketException

class MainActivity : FlutterActivity() {
    override fun onStart() {
        AnonWallet.setApplication(this)
        super.onStart()
    }

    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO);

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AnonWallet.setApplication(this)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        registerChannels(binaryMessenger)
    }


    override fun popSystemNavigator(): Boolean {
        WalletManager.getInstance().wallet?.let {
            it.store()
            it.close()
        }
        return super.popSystemNavigator()
    }

    override fun onPause() {
        WalletManager.getInstance().wallet?.let {
            it.store()
        }
        super.onPause()
    }

    override fun onDestroy() {
        WalletManager.getInstance().wallet?.let {
            it.store()
            it.close()
        }
        scope.cancel()
        super.onDestroy()
    }


    private fun registerChannels(binaryMessenger: BinaryMessenger) {
        /**
         * Wallet specific Event Methods
         */
        WalletEventsChannel.init(binaryMessenger, lifecycle)
        /**
         * Wallet specific Methods
         */
        WalletMethodChannel(binaryMessenger, lifecycle)
        /**
         * Wallet specific Methods
         */
        AddressMethodChannel(binaryMessenger, lifecycle)
        /**
         * Node specific Methods
         */
        NodeMethodChannel(binaryMessenger, lifecycle)
        /**
         * Spend specific Methods
         */
        SpendMethodChannel(binaryMessenger, lifecycle)
    }

}