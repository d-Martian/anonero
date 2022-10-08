package xmr.anon_wallet.wallet

import android.app.Application
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.channels.WalletEventsChannel
import java.io.File


object AnonWallet {

    private lateinit var application: Application;
    lateinit var walletDir: File
    private var currentWallet: Wallet? = null
    private val walletScope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()

    @JvmName("setApplication1")
    fun setApplication(flutterActivity: FlutterActivity) {
        this.application = flutterActivity.application
        initWalletPaths()
        attachScope(flutterActivity)
    }


    private fun initWalletPaths() {
        walletDir = File(application.filesDir, "wallets")
        if (!walletDir.exists()) {
            walletDir.mkdirs()
        }
    }

    fun getNetworkType(): NetworkType {
        return NetworkType.NetworkType_Stagenet
    }

    fun setWallet(wallet: Wallet) {
        this.currentWallet = wallet
    }

    fun getAppContext(): Application {
        return this.application
    }

    fun getScope(): CoroutineScope {
        return walletScope
    }
    private fun attachScope(flutterActivity: FlutterActivity) {
        with(flutterActivity) {
            lifecycle.addObserver(object : LifecycleEventObserver {
                override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                    if (event == Lifecycle.Event.ON_DESTROY) {
                        walletScope.cancel()
                    }
                }
            })
        }
    }

    fun getWallet(): Wallet? {
        return this.currentWallet
    }

}