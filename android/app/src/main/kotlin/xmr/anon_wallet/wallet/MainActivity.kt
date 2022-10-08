package xmr.anon_wallet.wallet

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import xmr.anon_wallet.wallet.channels.NodeMethodChannel
import xmr.anon_wallet.wallet.channels.WalletEventsChannel
import xmr.anon_wallet.wallet.channels.WalletMethodChannel
import xmr.anon_wallet.wallet.utils.AnonPreferences

class MainActivity : FlutterActivity() {
    override fun onStart() {

        AnonWallet.setApplication(this)
        super.onStart()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        registerChannels(binaryMessenger)
    }

    private fun registerChannels(binaryMessenger: BinaryMessenger) {
        /**
         * Wallet specific Event Methods
         */
        WalletEventsChannel.init(binaryMessenger,lifecycle)
        /**
         * Wallet specific Methods28089
         */
        WalletMethodChannel(binaryMessenger, lifecycle)
        /**
         * Node specific Methods
         */
        NodeMethodChannel(binaryMessenger, lifecycle)
    }

}