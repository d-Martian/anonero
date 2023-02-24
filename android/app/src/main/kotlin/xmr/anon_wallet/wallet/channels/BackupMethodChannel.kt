package xmr.anon_wallet.wallet.channels

import android.app.Activity
import android.content.Intent
import android.icu.text.SimpleDateFormat
import android.net.Uri
import android.util.Log
import androidx.core.net.toUri
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.WalletManager
import com.m2049r.xmrwallet.util.KeyStoreHelper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.MainActivity
import xmr.anon_wallet.wallet.restart
import xmr.anon_wallet.wallet.utils.AnonPreferences
import xmr.anon_wallet.wallet.utils.BackUpHelper
import xmr.anon_wallet.wallet.utils.EncryptUtil
import java.io.*
import java.util.*


class BackupMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle, private val activity: MainActivity) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle), PluginRegistry.ActivityResultListener {

    private var currentResult: Result? = null

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "backup" -> backup(call, result)
            "validatePayload" -> validatePayload(call, result)
            "openBackupFile" -> openBackupFile(call, result)
            "parseBackupFile" -> parseBackupFile(call, result)
            "parseBackup" -> parseBackup(call, result)
            "restore" -> restore(call, result)
            "restoreFromSeed" -> restoreFromSeed(call, result)
        }
    }

    private fun parseBackupFile(call: MethodCall, result: Result) {
        val uri = call.argument<String>("uri")?.toUri()
        val passphrase = call.argument<String>("passphrase")
        if (passphrase == null) {
            result.error("0", "Passphrase is null", null)
            return;
        }
        if (uri == null) {
            result.error("0", "Uri is null", null)
            return;
        }
        scope.launch {
            withContext(Dispatchers.IO) {
                val sb = StringBuilder()
                try {
                    val destFile = File(AnonWallet.getAppContext().cacheDir, "backup.anon").apply { createNewFile() }
                    val decryptedDestFile = File(AnonWallet.getAppContext().cacheDir, "backup.zip").apply { createNewFile() }
                    val extractDestination = File(AnonWallet.getAppContext().cacheDir, "tmp_extract")
                    val inPutStream = activity.contentResolver.openInputStream(uri)
                    inPutStream?.copyTo(destFile.outputStream())
                    inPutStream?.close()
                    EncryptUtil.decryptFile(passphrase, destFile, decryptedDestFile)
                    BackUpHelper.unZip(decryptedDestFile, extractDestination)
                    if (BackUpHelper.testBackUP(extractDestination)) {
                        File(extractDestination, "anon.json").inputStream().bufferedReader().useLines { lines -> lines.forEach { sb.append(it) } }
                        result.success(sb.toString())
                    } else {
                        result?.error("0", "Invalid backup", null)
                        BackUpHelper.cleanCacheDir()
                    }

                } catch (fnfe: FileNotFoundException) {
                    fnfe.printStackTrace()
                    result.error("1", "file not found", fnfe.message)
                } catch (ioe: IOException) {
                    ioe.printStackTrace()
                    result.error("1", "io exception", ioe.message)
                } catch (ioe: java.lang.Exception) {
                    ioe.printStackTrace()
                    result.error("1", "Unable to decrypt file", ioe.message)
                }
            }
        }
    }

    private fun restoreFromSeed(call: MethodCall, result: Result) {
        val seed = call.argument<String>("seed")
        val height = call.argument<Int>("height") ?: 1
        val pin = call.argument<String>("pin")
        val passPhrase = call.argument<String?>("passPhrase")
        val walletFileName = "default"
        scope.launch {
            withContext(Dispatchers.IO) {
                val walletFile = File(AnonWallet.walletDir, walletFileName)
                WalletManager.getInstance().recoveryWallet(walletFile, pin, seed, passPhrase ?: "", height.toLong());
                AnonPreferences(context = AnonWallet.getAppContext()).passPhraseHash = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), passPhrase)
                //wait for preferences to be saved
                delay(800)
                result.success(true)
                activity.restart()
            }
        }
    }

    private fun openBackupFile(call: MethodCall, result: Result) {
        currentResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "*/*"
        }
        activity.startActivityForResult(intent, BACK_UP_READ_CODE)
    }

    private fun restore(call: MethodCall, result: Result) {
        this.scope.launch {
            withContext(Dispatchers.IO) {
                if (payloadParsed == null) {
                    result.error("payload", "Invalid payload", null)
                    return@withContext;
                }
                val tmpBackupDir = File(AnonWallet.getAppContext().cacheDir, "tmp_extract")
                val anonDir = AnonWallet.walletDir
                tmpBackupDir.listFiles()?.forEach { entry ->
                    if (!entry.isDirectory && !entry.name.contains("anon.json")) {
                        entry.copyTo(File(anonDir, entry.name), true)
                    }
                }
                AnonPreferences(context = AnonWallet.getAppContext()).passPhraseHash = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), mnemonicPassphrase)
                //wait for preferences to be saved
                delay(800)
                result.success(true)
                activity.restart()
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
                    scope.launch {
                        withContext(Dispatchers.IO) {
                            writeExportFile(data?.data)
                        }
                    }
                }
                if (resultCode == Activity.RESULT_CANCELED) {
                    currentResult?.success(false)
                    //No operation
                }
            }
            BACK_UP_READ_CODE -> {
                if (resultCode == Activity.RESULT_CANCELED) {
                    currentResult?.error("0", "canceled", null)
                } else {
                    currentResult?.success(data?.data!!.toString())
                }
            }
        }
        return true

    }

    private fun backup(call: MethodCall, result: Result) {
        scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val seedPassphrase = call.argument<String?>("seedPassphrase")
                    val hash = AnonPreferences(AnonWallet.getAppContext()).passPhraseHash
                    val hashedPass = KeyStoreHelper.getCrazyPass(AnonWallet.getAppContext(), seedPassphrase)
                    if (hashedPass == hash) {
                        scope.launch {
                            withContext(Dispatchers.IO) {
                                val path = BackUpHelper.createBackUp(seedPassphrase ?: "", activity.applicationContext)
                                WalletMethodChannel.backupPath = path
                                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                    addCategory(Intent.CATEGORY_OPENABLE)
                                    type = "*/*"
                                    putExtra(Intent.EXTRA_TITLE, File(path).name)
                                }
                                currentResult = result
                                activity.startActivityForResult(intent, BACKUP_EXPORT_CODE)
                            }
                        }
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

    private fun parseBackup(call: MethodCall, result: Result) {

        val uri = call.argument<String>("backupFileUri")?.toUri()
        val passphrase = call.argument<String>("passphrase")
        if (passphrase == null) {
            result.error("0", "Passphrase is null", null)
            return;
        }
        if (uri == null) {
            result.error("0", "Uri is null", null)
            return;
        }
        scope.launch {
            withContext(Dispatchers.IO) {
                val backupMeta = StringBuilder()
                try {
                    activity.cacheDir.deleteRecursively()
                    val destFile = File(AnonWallet.getAppContext().cacheDir, "backup.anon").apply { createNewFile() }
                    val decryptedDestFile = File(AnonWallet.getAppContext().cacheDir, "backup.zip").apply { createNewFile() }
                    val extractDestination = File(AnonWallet.getAppContext().cacheDir, "tmp_extract")
                    val inPutStream = activity.contentResolver.openInputStream(uri)
                    inPutStream?.copyTo(destFile.outputStream())
                    inPutStream?.close()
                    EncryptUtil.decryptFile(passphrase, destFile, decryptedDestFile)
                    BackUpHelper.unZip(decryptedDestFile, extractDestination)
                    if (BackUpHelper.testBackUP(extractDestination)) {
                        File(extractDestination, "anon.json").inputStream().bufferedReader().useLines { lines -> lines.forEach { backupMeta.append(it) } }

                    } else {
                        result.error("0", "Invalid backup", null)
                        BackUpHelper.cleanCacheDir()
                    }

                } catch (fnfe: FileNotFoundException) {
                    fnfe.printStackTrace()
                    result.error("1", "file not found", fnfe.message)
                } catch (ioe: IOException) {
                    ioe.printStackTrace()
                    result.error("1", "io exception", ioe.message)
                } catch (ioe: java.lang.Exception) {
                    ioe.printStackTrace()
                    result.error("1", "Unable to decrypt file", ioe.message)
                }
                val backUpPayloadObj = JSONObject(backupMeta.toString())
                if (backUpPayloadObj.has("backup")) {
                    try {
                        val backUpPayload = backUpPayloadObj.getString("backup")
                        payloadParsed = JSONObject(backUpPayload)
                        mnemonicPassphrase = passphrase
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
                    } catch (e: Exception) {
                        result.error("2", e.message, "")
                    }
                }
            }
        }
    }

    private suspend fun writeExportFile(data: Uri?) {
        if (data != null) {
            try {
                val os = activity.contentResolver.openOutputStream(data)
                val file = File(WalletMethodChannel.backupPath)
                os?.use {
                    file.inputStream().copyTo(it)
                }
                os?.close()
                withContext(Dispatchers.Main) {
                    currentResult?.success(true)
                }
            } catch (e: IOException) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    currentResult?.error("0", "io exception", e.message)
                }
            } finally {
                WalletMethodChannel.backupPath = null
            }
        }
    }


    private fun parseBackUP(call: MethodCall, result: Result) {
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