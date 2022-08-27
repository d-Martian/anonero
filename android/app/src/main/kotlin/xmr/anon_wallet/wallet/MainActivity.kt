package xmr.anon_wallet.wallet

import android.util.Log
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import java.io.File

class MainActivity : FlutterActivity() {


    override fun onStart() {
        super.onStart()
        createWallet()
    }

    fun createWallet() {
        val dir = File(context.filesDir, "app")
        val cacheFile: File = File(dir, "anon")
        val keysFile: File = File(dir, "anon" + ".keys")
        val addressFile: File = File(dir, "anon" + ".address.txt")
        val newWallet: Wallet = WalletManager.getInstance()
            .createWallet(
                dir, "testaccount", "English", 18844L,
            )
        Log.i("TAG", "Wallet Status: ${newWallet.status}")
        Log.i("TAG", "Wallet Address: ${newWallet.address}")
        Log.i("TAG", "Wallet Seed: ${newWallet.getSeed("OFFSET")}")
    }
}
