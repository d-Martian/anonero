package xmr.anon_wallet.wallet

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.os.PowerManager.WakeLock
import android.os.Process
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.channels.*
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.plugins.qrScanner.AnonQRCameraPlugin
import xmr.anon_wallet.wallet.utils.AnonPreferences


class MainActivity : FlutterActivity() {

    override fun onStart() {
        AnonWallet.setApplication(this)
        super.onStart()
    }

    private var wakeLock: WakeLock? = null
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO)
    private  var cameraPlugin : AnonQRCameraPlugin? = null

    @SuppressLint("WakelockTimeout")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        makeChannel()
        AnonWallet.setApplication(this)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        registerChannels(binaryMessenger)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        wakeLock = (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "wallet:wakelock").apply {
                acquire()
            }
        }
        initializeProxySettings()
        cameraPlugin = AnonQRCameraPlugin(this, binaryMessenger, lifecycle)
        cameraPlugin?.let {
            flutterEngine.plugins.add(it)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        cameraPlugin?.onRequestPermissionsResult()
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun initializeProxySettings() {
        val prefs = AnonPreferences(this)
        if (prefs.firstRun == true) {
            prefs.proxyServer = "127.0.0.1"
            prefs.proxyPort = "9050"
            prefs.firstRun = false
        }
    }

    private fun makeChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                AnonWallet.NOTIFICATION_CHANNEL_ID,
                "Transactions Notification",
                NotificationManager.IMPORTANCE_HIGH
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onResume() {
        super.onResume()
        scope.launch {
            withContext(Dispatchers.IO) {
                WalletEventsChannel.initWalletListeners()
                WalletManager.getInstance().wallet?.let {
                    it.startRefresh()
                    it.refreshHistory()
                    WalletEventsChannel.sendEvent(it.walletToHashMap())
                }
            }
        }
    }

    override fun onDestroy() {
        scope.launch {
            withContext(Dispatchers.IO) {
                WalletManager.getInstance().wallet?.let {
                    it.store()
                    it.close()
                }
            }
        }
        scope.cancel()
        super.onDestroy()
        //kill process
        Process.killProcess(Process.myPid())
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
