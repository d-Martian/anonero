package xmr.anon_wallet.wallet

 import androidx.annotation.NonNull
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.channels.*


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
    override fun onPause() {
        scope.launch {
            withContext(Dispatchers.IO){
                WalletManager.getInstance().wallet?.let {
                    it.store()
                }
            }
        }
        super.onPause()
    }

    override fun onStop() {
        scope.launch {
            withContext(Dispatchers.IO){
                WalletManager.getInstance().wallet?.let {
                    it.store()
                    it.close()
                }
            }
        }
        super.onStop()
    }

    override fun onDestroy() {
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