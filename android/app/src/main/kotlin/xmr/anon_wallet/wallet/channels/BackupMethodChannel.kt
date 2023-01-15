package xmr.anon_wallet.wallet.channels

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.icu.text.SimpleDateFormat
import android.net.Uri
import android.util.Log
import androidx.camera.core.impl.utils.ContextUtil.getApplicationContext
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.NetworkType
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.util.KeyStoreHelper
import com.m2049r.xmrwallet.utils.RestoreHeight
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.MainActivity
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import xmr.anon_wallet.wallet.utils.AnonPreferences
import xmr.anon_wallet.wallet.utils.BackUpHelper
import xmr.anon_wallet.wallet.utils.EncryptUtil
import java.io.*
import java.util.*


class BackupMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle, private val activity: MainActivity) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle), PluginRegistry.ActivityResultListener {

    private var currentResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "backup" -> backup(call, result)
            "validatePayload" -> validatePayload(call, result)
            "openBackupFile" -> openBackupFile(call, result)
            "shareToFile" -> shareToFile(call, result)
            "parseBackup" -> parseBackup(call, result)
            "restore" -> restore(call, result)
        }
    }

    private fun openBackupFile(call: MethodCall, result: Result) {
        currentResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "text/plain"
        }
        activity.startActivityForResult(intent, BACK_UP_READ_CODE)
    }

    private fun restore(call: MethodCall, result: Result) {
        this.scope.launch {
            withContext(Dispatchers.IO){
                if(payloadParsed == null){
                    result.error("payload", "Invalid payload", null)
                    return@withContext;
                }
                val  pin = call.argument<String>("pin")
                val walletPayload = payloadParsed!!.getJSONObject("wallet")
                val meta = payloadParsed!!.getJSONObject("meta")
                if (meta.getString("network").equals(AnonWallet.getNetworkType().toString())) {
                    val seed = walletPayload.getString("seed");
                    val restoreHeightFromPayload = walletPayload.getLong("restoreHeight")
                    val walletName = "default"
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
                    val newWalletFile = File(AnonWallet.walletDir, walletName)
                    val wallet = WalletManager.getInstance().recoveryWallet(newWalletFile, pin, seed, mnemonicPassphrase, restoreHeightFromPayload)
                    wallet.store()
                    AnonPreferences(context = AnonWallet.getAppContext()).passPhraseHash = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), mnemonicPassphrase)
                    AnonPreferences(context = AnonWallet.getAppContext()).isRestoredFromBackup =  true
                    WalletManager.getInstance().close(wallet)
                    delay(900)
                    Runtime.getRuntime().exit(0)
                }
                result.success(true)
            }
        }
    }

    private fun validatePayload(call: MethodCall, result: Result) {
        currentResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "text/plain"
        }
        activity.startActivityForResult(intent, BACK_UP_READ_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            BACKUP_EXPORT_CODE -> {
                if (resultCode == Activity.RESULT_OK) {
                    writeExportFile(data?.data)
                }
                if (resultCode == Activity.RESULT_CANCELED) {
                    //No operation
                }

            }
            BACK_UP_READ_CODE -> {
                if (resultCode == Activity.RESULT_CANCELED) {
                    currentResult?.error("0", "canceled", null)
                } else {
                    scope.launch {
                        withContext(Dispatchers.IO) {
                            val sb = StringBuilder()
                            try {
                                val inPutStream = BufferedReader(InputStreamReader(activity.contentResolver.openInputStream(data?.data!!)))
                                var str: String?
                                while (inPutStream.readLine().also { str = it } != null) {
                                    sb.append(str)
                                }
                                inPutStream.close()
                                currentResult?.success(sb.toString())
                            } catch (fnfe: FileNotFoundException) {
                                fnfe.printStackTrace()
                                currentResult?.error("0", "file not found", fnfe.message)
                            } catch (ioe: IOException) {
                                ioe.printStackTrace()
                                currentResult?.error("0", "io exception", ioe.message)
                            }
                            currentResult = null;
                        }
                    }

                }
            }
        }
        return true
    }

    private fun backup(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val seedPassphrase = call.argument<String?>("seedPassphrase")
                    val hash = AnonPreferences(AnonWallet.getAppContext()).passPhraseHash
                    val hashedPass = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), seedPassphrase)
                    if (hashedPass == hash) {
                        result.success(seedPassphrase?.let { BackUpHelper.createBackUp(it) })
                    } else {
                        result.error("1", "Invalid passphrase", "")
                    }
                } catch (e: Exception) {
                    result.error("2", e.message, "")
                    e.printStackTrace()
                }
            }
        }
    }

    private fun shareToFile(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val date = Date()
                    val sdf = SimpleDateFormat("dd_MM_yyyy' 'HH_mm_a", Locale.getDefault())
                    val timeStamp: String = sdf.format(date)
                    val string = call.argument<String>("backup")
                    WalletMethodChannel.backupString = string
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TITLE, "anon_backup_${timeStamp}")
                    }
                    activity.startActivityForResult(intent, BACKUP_EXPORT_CODE)
                } catch (e: Exception) {
                    result.error("2", e.message, "")
                    e.printStackTrace()
                }
            }
        }
    }

    private fun parseBackup(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                val backup = call.argument<String>("backup");
                val passphrase = call.argument<String>("passphrase") ?: "";
                val backUpPayloadObj = JSONObject(backup)
                if (backUpPayloadObj.has("backup")) {
                    try {
                        val backUpPayload = backUpPayloadObj.getString("backup")
                        val payload = EncryptUtil.decrypt(passphrase, backUpPayload);
                        payloadParsed = JSONObject(payload)
                        mnemonicPassphrase = passphrase;
                        if (payloadParsed == null) {
                            result.error("0", "Unable to parse backup", "");
                            return@withContext
                        } else {
                            val meta = payloadParsed!!.getJSONObject("meta")
                            if (meta.getString("network") != AnonWallet.getNetworkType().toString()) {
                                result.error("1", "Incompatible network", "");
                                return@withContext
                            }
                            result.success(payloadParsed.toString())
                            return@withContext;
                        }
//
                    } catch (e: Exception) {
                        result.error("2", e.message, "")
                    }
                }
            }
        }
    }

    private fun writeExportFile(data: Uri?) {
        if (data != null) {
            try {
                val os = activity.contentResolver.openOutputStream(data)
                os?.write((WalletMethodChannel.backupString ?: "").toByteArray());
                os?.close()
            } catch (e: IOException) {
                e.printStackTrace()
            } finally {
                WalletMethodChannel.backupString = null
            }
        }
    }


    private fun parseBackUP(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                val payload = call.argument<String>("payload");
                val passphrase = call.argument<String>("passphrase");
                val json = JSONObject(payload)
                val version = json.getString("version")
                val backup = json.getString("backup")
            }
        }
    }

    companion object {
        private const val TAG = "WalletMethodChannel"
        const val CHANNEL_NAME = "backup.channel"
        const val BACKUP_EXPORT_CODE = 40
        const val BACK_UP_READ_CODE = 12
        var payloadParsed: JSONObject? = null
        var mnemonicPassphrase: String = ""
    }

}