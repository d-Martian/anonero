package xmr.anon_wallet.wallet.utils

import android.content.Context
import android.icu.text.SimpleDateFormat
import com.m2049r.xmrwallet.model.WalletManager
import org.json.JSONObject
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.services.NodeManager
import java.io.*
import java.util.*
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipOutputStream

object BackUpHelper {
    private const val BACKUP_VERSION = "1.0"
    const val BUFFER = 2048

    fun createBackUp(seedPassphrase: String, context: Context): String {
        val wallet = WalletManager.getInstance().wallet

        val walletPayload = JSONObject()
            .apply {
                put("address", wallet.address)
                put("seed", wallet.getSeed(seedPassphrase))
                put("restoreHeight", wallet.restoreHeight)
                put("balanceAll", wallet.balanceAll)
                put("numSubaddresses", wallet.numSubaddresses)
                put("numAccounts", wallet.numAccounts)
                put("isWatchOnly", wallet.isWatchOnly)
                put("isSynchronized", wallet.isSynchronized)
            }
        val nodePayload = JSONObject()
            .apply {
                NodeManager.getNode()?.let { nodeInfo ->
                    put("host", nodeInfo.host)
                    put("password", nodeInfo.password)
                    put("username", nodeInfo.username)
                    put("rpcPort", nodeInfo.rpcPort)
                    put("networkType", nodeInfo.networkType)
                    put("isOnion", nodeInfo.isOnion)
                }
            }

        val metaPayload = JSONObject().apply {
            put("timestamp", System.currentTimeMillis())
            put("network", AnonWallet.getNetworkType().toString())
        }
        val backUpPayload = JSONObject().apply {
            put("node", nodePayload)
            put("wallet", walletPayload)
            put("meta", metaPayload)
        }


        val json = JSONObject().apply {
            put("version", BACKUP_VERSION)
            put("backup", backUpPayload)
        }.toString()

        context.cacheDir.deleteRecursively();

        val tmpBackupDir = File(context.cacheDir, "tmp_backup");
        if (tmpBackupDir.exists()) {
            tmpBackupDir.deleteRecursively()
        }
        val date = Date()
        val sdf = SimpleDateFormat("dd_MM_yyyy' 'HH_mm_a", Locale.getDefault())
        val timeStamp: String = sdf.format(date)
        val backupFile = File(context.cacheDir, "anon_backup_$timeStamp.zip")
        tmpBackupDir.mkdirs()
        val tmpBackupFile = File(tmpBackupDir, "anon.json");
        tmpBackupFile.writeText(json)
        val walletDir = File(context.filesDir, "wallets")
        walletDir.copyRecursively(tmpBackupDir, true)
        val list = tmpBackupDir.listFiles()
        val files = list?.map { it.absolutePath }?.toTypedArray()
        val backupFileEncrypted = File(context.cacheDir, "anon_backup_$timeStamp.anon")

        if (files != null) {
            zip(files, backupFile.absolutePath)
            EncryptUtil.encryptFile(seedPassphrase, backupFile, backupFileEncrypted)
            backupFile.delete()
        }
        return backupFileEncrypted.absolutePath
    }

    fun testBackUP(destinationDir: File): Boolean {
        val items = destinationDir.listFiles().toList().filter {
            (it.name.endsWith(".keys") || it.name.endsWith(".json"))
        }
        return items.size == 2
    }

    private fun zip(_files: Array<String>, zipFileName: String?) {
        try {
            var origin: BufferedInputStream?
            val dest = FileOutputStream(zipFileName)
            val out = ZipOutputStream(
                BufferedOutputStream(
                    dest
                )
            )
            val data = ByteArray(BUFFER)
            for (i in _files.indices) {
                val fi = FileInputStream(_files[i])
                origin = BufferedInputStream(fi, BUFFER)
                val entry = ZipEntry(_files[i].substring(_files[i].lastIndexOf("/") + 1))
                out.putNextEntry(entry)
                var count: Int
                while (origin.read(data, 0, BUFFER).also { count = it } != -1) {
                    out.write(data, 0, count)
                }
                origin.close()
            }
            out.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun unZip(toUnzip: File, destinationDir: File) {
        destinationDir.apply {
            if (!exists()) {
                mkdirs()
            }
        }
        ZipFile(toUnzip).use { zip ->
            zip.entries().asSequence().forEach { entry ->
                zip.getInputStream(entry).use { input ->
                    val filePath = "${destinationDir}${File.separator}${entry.name}"
                    if (!entry.isDirectory) {
                        input.copyTo(File(filePath).apply { createNewFile() }.outputStream())
                    } else {
                        val dir = File(filePath)
                        dir.mkdir()
                    }
                }
            }
        }
    }

    fun cleanCacheDir() {
        AnonWallet.getAppContext().cacheDir.deleteRecursively()
    }
}