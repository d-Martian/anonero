package xmr.anon_wallet.wallet

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import xmr.anon_wallet.wallet.channels.WalletMethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        registerChannels(binaryMessenger)
    }

    private fun registerChannels(binaryMessenger: BinaryMessenger) {
        /**
         * Wallet specific Methods
         */
        WalletMethodChannel(binaryMessenger, lifecycle)
    }

}
