package xmr.anon_wallet.wallet.utils

import org.bouncycastle.crypto.digests.SHA256Digest
import org.bouncycastle.crypto.generators.PKCS5S2ParametersGenerator
import org.bouncycastle.crypto.params.KeyParameter
import org.bouncycastle.util.encoders.Base64
import java.io.*
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.CipherInputStream
import javax.crypto.CipherOutputStream
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

object EncryptUtil {

    const val DEFAULT_ITR = 11000
    const val SALT_PREFIX = "Salted__"
    const val BUFFER_SIZE = 4096


    fun encrypt(
        password: String,
        toEncrypt: String
    ): String {
        val salt = SecureRandom().generateSeed(8)
        // Derive 48 byte key
        var keySpec: SecretKeySpec?;
        var ivSpec: IvParameterSpec?;
        PKCS5S2ParametersGenerator(SHA256Digest()).let { generator ->
            generator.init(password.toByteArray(), salt, DEFAULT_ITR)
            (generator.generateDerivedMacParameters(48 * 8) as KeyParameter).key.let { secretKey ->
                val bytes = secretKey.copyOfRange(0, 32);
                keySpec = SecretKeySpec(bytes, "AES")
                ivSpec = IvParameterSpec(secretKey.copyOfRange(32, secretKey.size))
                generator.password.fill('*'.code.toByte())
                secretKey.fill('*'.code.toByte())
            }
        }
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
        val cipherText = cipher.doFinal(toEncrypt.toByteArray())
        return Base64.encode(SALT_PREFIX.toByteArray() + salt + cipherText)
            .decodeToString()
            .replace("(.{64})".toRegex(), "$1\n")

    }

    fun decrypt(
        password: String,
        toDecrypt: String
    ): String {
        val encryptedBytes = Base64.decode(toDecrypt.lines().joinToString(""))
        val salt = encryptedBytes.copyOfRange(8, 16)
        // Derive 48 byte key
        var keySpec: SecretKeySpec?;
        var ivSpec: IvParameterSpec?;
        PKCS5S2ParametersGenerator(SHA256Digest()).let { generator ->
            generator.init(password.toByteArray(), salt, DEFAULT_ITR)
            (generator.generateDerivedMacParameters(48 * 8) as KeyParameter).key.let { secretKey ->
                // Decryption Key is bytes 0 - 31 of the derived secret key
                val bytes = secretKey.copyOfRange(0, 32);
                keySpec = SecretKeySpec(bytes, "AES")
                // Input Vector is bytes 32 - 47 of the derived secret key
                ivSpec = IvParameterSpec(secretKey.copyOfRange(32, secretKey.size))
                generator.password.fill('*'.toByte())
                secretKey.fill('*'.toByte())
            }
        }
        val cipherText = encryptedBytes.copyOfRange(16, encryptedBytes.size)
        // Decrypt the Cipher Text and manually remove padding after
        val cipher = Cipher.getInstance("AES/CBC/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)
        val decrypted = cipher.doFinal(cipherText)
        // Last byte of the decrypted text is the number of padding bytes needed to remove
        val plaintext = decrypted.copyOfRange(0, decrypted.size - decrypted.last().toInt())
        return plaintext.toString(Charsets.UTF_8)

    }

    fun encryptFile(key: String, inputFile: File, outputFile: File) {
        val salt = SecureRandom().generateSeed(8)
        // Derive 48 byte key
        var keySpec: SecretKeySpec?;
        var ivSpec: IvParameterSpec?;
        PKCS5S2ParametersGenerator(SHA256Digest()).let { generator ->
            generator.init(key.toByteArray(), salt, DEFAULT_ITR)
            (generator.generateDerivedMacParameters(48 * 8) as KeyParameter).key.let { secretKey ->
                val bytes = secretKey.copyOfRange(0, 32);
                keySpec = SecretKeySpec(bytes, "AES")
                ivSpec = IvParameterSpec(secretKey.copyOfRange(32, secretKey.size))
                generator.password.fill('*'.code.toByte())
                secretKey.fill('*'.code.toByte())
            }
        }
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
        val fileInputStream = FileInputStream(inputFile)
        val fileOutputStream = FileOutputStream(outputFile);
        val cipherOutputStream = CipherOutputStream(BufferedOutputStream(fileOutputStream), cipher)
        fileOutputStream.write((SALT_PREFIX.toByteArray() + salt))
        fileInputStream.copyTo(cipherOutputStream, BUFFER_SIZE)
        fileInputStream.close()
        cipherOutputStream.close()

    }

    fun decryptFile(key: String, inputFile: File, outputFile: File) {
        val fis = FileInputStream(inputFile)
        val prefix = ByteArray(16)
        fis.read(prefix)
        //Extract salt from the input file, 0-8 is the salt prefix, 8-16 is the salt
        val salt = prefix.copyOfRange(8, 16)
        var keySpec: SecretKeySpec?
        var ivSpec: IvParameterSpec?
        PKCS5S2ParametersGenerator(SHA256Digest()).let { generator ->
            generator.init(key.toByteArray(), salt, DEFAULT_ITR)
            (generator.generateDerivedMacParameters(48 * 8) as KeyParameter).key.let { secretKey ->
                val bytes = secretKey.copyOfRange(0, 32);
                keySpec = SecretKeySpec(bytes, "AES")
                ivSpec = IvParameterSpec(secretKey.copyOfRange(32, secretKey.size))
                generator.password.fill('*'.code.toByte())
                secretKey.fill('*'.code.toByte())
            }
        }
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)
        val fileInputStream = inputFile.inputStream()
        // Skip the salt prefix and salt
        fileInputStream.skip(16)
        val cis = CipherInputStream(BufferedInputStream(fileInputStream), cipher)
        val fos = outputFile.outputStream()
        cis.copyTo(fos, BUFFER_SIZE)
        cis.close()
        fos.close()
    }

}