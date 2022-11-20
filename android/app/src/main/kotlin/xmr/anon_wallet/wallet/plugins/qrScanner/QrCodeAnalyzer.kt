package xmr.anon_wallet.wallet.plugins.qrScanner

import android.graphics.ImageFormat
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.multi.qrcode.QRCodeMultiReader
import java.nio.ByteBuffer


class QrCodeAnalyzer(
    private val onQrCodesDetected: (qrCode: Result) -> Unit
) : ImageAnalysis.Analyzer {


    private fun ByteBuffer.toByteArray(): ByteArray {
        rewind()
        val data = ByteArray(remaining())
        get(data)
        return data
    }

    private val yuvFormats = mutableListOf(ImageFormat.YUV_420_888)

    init {
        yuvFormats.addAll(listOf(ImageFormat.YUV_422_888, ImageFormat.YUV_444_888))
    }


    private val reader = QRCodeMultiReader()

    override fun analyze(image: ImageProxy) {
        // We are using YUV format because, ImageProxy internally uses ImageReader to get the image
        // by default ImageReader uses YUV format unless changed.
        if (image.format !in yuvFormats) {
            return
        }
        val data = image.planes[0].buffer.toByteArray()

        val source = PlanarYUVLuminanceSource(
            data,
            image.width,
            image.height,
            0,
            0,
            image.width,
            image.height,
            false
        )

        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
        try {
            // it throws NotFoundException
            val result = reader.decode(binaryBitmap)
            onQrCodesDetected(result)
        } catch (e: NotFoundException) {
//            e.printStackTrace()
        } catch (e: ChecksumException) {
//            e.printStackTrace()
        } catch (e: Exception) {
//            e.printStackTrace()
        }
        image.close()
    }
}
