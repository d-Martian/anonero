package xmr.anon_wallet.wallet

import android.app.Application
import android.util.Log
import androidx.datastore.core.DataStore
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.Wallet
import xmr.anon_wallet.wallet.utils.PreferenceStore
import java.io.File


object AnonWallet {

    private lateinit var application: Application;
    lateinit var walletDir: File
    private var currentWallet: Wallet? = null;

    @JvmName("setApplication1")
    fun setApplication(application: Application) {
        this.application = application
        initWalletPaths()
        PreferenceStore.init()
    }

    private fun initWalletPaths() {
        walletDir = File(application.filesDir, "wallets")
        if (!walletDir.exists()) {
            walletDir.mkdirs()
        }
    }

    fun getNetworkType(): NetworkType {
        return NetworkType.NetworkType_Testnet
    }

    fun setWallet(wallet: Wallet) {
        this.currentWallet = wallet
    }

    fun getAppContext(): Application {
        return this.application
    }

    fun getWallet(): Wallet? {
        return this.currentWallet
    }
}