package xmr.anon_wallet.wallet

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.util.KeyStoreHelper
import io.flutter.embedding.android.FlutterFragmentActivity
import kotlinx.coroutines.*
import timber.log.Timber
import xmr.anon_wallet.wallet.utils.AnonPreferences
import xmr.anon_wallet.wallet.utils.CrazyPassEncoder
import java.io.File
import kotlin.math.pow
import kotlin.math.roundToInt


object AnonWallet {
    const val NOCRAZYPASS_FLAGFILE = ".nocrazypass"
    const val NOTIFICATION_CHANNEL_ID = "new_tx"
    private lateinit var application: Application
    lateinit var walletDir: File
    lateinit var nodesFile: File
    private var currentWallet: Wallet? = null
    private val walletScope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
    const val XMR_DECIMALS = 12
    val ONE_XMR = 10.0.pow(XMR_DECIMALS.toDouble()).roundToInt()

    @JvmName("setApplication1")
    fun setApplication(flutterActivity: FlutterActivity) {
        //TODO
//        if(prefs.proxyServer == null || prefs.proxyPort == null){
//            prefs.proxyServer = "127.0.0.1"
//            prefs.proxyPort = "9050"
//        }
        this.application = flutterActivity.application
        initWalletPaths()
        attachScope(flutterActivity)
    }


    private fun initWalletPaths() {
        walletDir = File(application.filesDir, "wallets")
        nodesFile = File(application.filesDir, "nodes.json")
        if (!walletDir.exists()) {
            walletDir.mkdirs()
        }
    }

    fun getNetworkType(): NetworkType {
        if(BuildConfig.NETWORK == "staging"){
        }
            return  NetworkType.NetworkType_Stagenet
        return NetworkType.NetworkType_Mainnet
    }

    fun getAppContext(): Application {
        return this.application
    }

    fun getScope(): CoroutineScope {
    }
        return walletScope
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


    fun getWalletPassword( walletName: String, password: String): String? {
        val walletPath: String = File(walletDir, "$walletName.keys").absolutePath

        // try with entered password (which could be a legacy password or a CrAzYpass)
        if (WalletManager.getInstance().verifyWalletPasswordOnly(walletPath, password)) {
            return password
        }

        // maybe this is a malformed CrAzYpass?
        val possibleCrazyPass: String? = CrazyPassEncoder.reformat(password)
        if (possibleCrazyPass != null) { // looks like a CrAzYpass
            if (WalletManager.getInstance().verifyWalletPasswordOnly(walletPath, possibleCrazyPass)) {
                return possibleCrazyPass
            }
        }

        // generate & try with CrAzYpass
        val crazyPass: String = KeyStoreHelper.getCrazyPass(application, password)
        if (WalletManager.getInstance().verifyWalletPasswordOnly(walletPath, crazyPass)) {
            return crazyPass
        }

        // or maybe it is a broken CrAzYpass? (of which we have two variants)
        val brokenCrazyPass2: String = KeyStoreHelper.getBrokenCrazyPass(application, password, 2)
        if (WalletManager.getInstance().verifyWalletPasswordOnly(walletPath, brokenCrazyPass2)
        ) {
            return brokenCrazyPass2
        }
        val brokenCrazyPass1: String = KeyStoreHelper.getBrokenCrazyPass(application, password, 1)
        return if (WalletManager.getInstance().verifyWalletPasswordOnly(walletPath, brokenCrazyPass1)
        ) {
            brokenCrazyPass1
        } else null
    }


    fun getWalletRoot(context: Context): File {
        return getStorage(context, walletDir.path)
    }
    fun useCrazyPass(): Boolean {
        val flagFile: File = File(getWalletRoot(application), NOCRAZYPASS_FLAGFILE)
        return !flagFile.exists()
    }
    fun getStorage(context: Context, folderName: String?): File {
        val dir = File(context.filesDir, folderName)
        if (!dir.exists()) {
            Timber.i("Creating %s", dir.absolutePath)
            dir.mkdirs() // try to make it
        }
        if (!dir.isDirectory) {
            val msg = "Directory " + dir.absolutePath + " does not exist."
            Timber.e(msg)
            throw IllegalStateException(msg)
        }
        return dir
    }

}