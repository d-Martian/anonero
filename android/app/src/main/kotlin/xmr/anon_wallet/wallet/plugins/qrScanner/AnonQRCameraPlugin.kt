package xmr.anon_wallet.wallet.plugins.qrScanner


import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.view.Surface
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.shouldShowRequestPermissionRationale
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import anon.xmr.app.anon_wallet.BuildConfig
import com.google.common.util.concurrent.ListenableFuture
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.view.TextureRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.MainActivity

import xmr.anon_wallet.wallet.channels.AnonMethodChannel
import java.util.concurrent.Executors

class AnonQRCameraPlugin(
    private val activity: MainActivity, messenger: BinaryMessenger, lifecycle: Lifecycle
) : FlutterPlugin, AnonMethodChannel(messenger, "anon_camera", lifecycle), EventChannel.StreamHandler {


    private val qrEventChannel = EventChannel(
        messenger, "anon_camera:events"
    )
    private var eventSink: EventSink? = null
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    private var registry: TextureRegistry? = null
    private var cameraProviderFuture: ListenableFuture<ProcessCameraProvider> = ProcessCameraProvider.getInstance(activity)
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null


    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        registry = binding.textureRegistry
        qrEventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        stopCamera()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startCam" -> startCam(call, result)
            "stopCam" -> stopCamera()
            "checkPermissionState" -> checkPermissionState(call, result)
            "requestPermission" -> requestPermission()
        }
    }

    private fun checkPermissionState(call: MethodCall, result: Result) {
        result.success(isPermissionGranted())
    }

    private fun requestPermission() {
        if (ContextCompat.checkSelfPermission(
                activity, Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            startCamera()
        } else if (shouldShowRequestPermissionRationale(activity, Manifest.permission.CAMERA)) {
            activity.startActivity(Intent().apply {
                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                data = Uri.fromParts("package", BuildConfig.APPLICATION_ID, null)
            })
        } else {
            ActivityCompat.requestPermissions(activity, REQUIRED_PERMISSIONS, 2)
        }
    }

    fun onRequestPermissionsResult() {
        if (isPermissionGranted()) {
            startCamera()
        } else {

        }
    }


    private fun startCam(call: MethodCall, result: Result) {
        if (isPermissionGranted()) {
            startCamera()
        } else {
            result.error("1", "PERMISSION", null)
        }
    }

    private fun startCamera() {
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            cameraProvider!!.unbindAll()

            textureEntry = registry?.createSurfaceTexture()

            val cameraSelector = CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build()

            val surfaceProvider = Preview.SurfaceProvider { request ->
                val texture = textureEntry!!.surfaceTexture()
                texture.setDefaultBufferSize(
                    request.resolution.width, request.resolution.height
                )
                val surface = Surface(texture)
                request.provideSurface(surface, cameraExecutor) {}
            }

            val previewBuilder = Preview.Builder()
            preview = previewBuilder.build().apply { setSurfaceProvider(surfaceProvider) }

            val imageAnalysis = ImageAnalysis.Builder().setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST).build().also {
                it.setAnalyzer(cameraExecutor, QrCodeAnalyzer { qrResult ->
                    scope.launch {
                        withContext(Dispatchers.Main) {
                            eventSink?.success(
                                hashMapOf(
                                    "result" to qrResult.text
                                )
                            )
                        }
                    }
                })
            }

            camera = cameraProvider?.bindToLifecycle(
                activity as LifecycleOwner, cameraSelector, preview, imageAnalysis
            )

            val resolution = preview?.resolutionInfo!!.resolution
            val portrait = camera!!.cameraInfo.sensorRotationDegrees % 180 == 0
            val width = resolution.width.toDouble()
            val height = resolution.height.toDouble()

            if (textureEntry != null) {
                eventSink?.success(
                    hashMapOf(
                        "id" to textureEntry!!.id(),
                        "width" to if (portrait) width else height,
                        "height" to if (portrait) height else width,
                    )
                )
            } else {

            }

        }, ContextCompat.getMainExecutor(activity))
    }

    private fun isPermissionGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun stopCamera() {
        val owner = activity as LifecycleOwner
        camera?.cameraInfo?.torchState?.removeObservers(owner)
        cameraProvider?.unbindAll()
        textureEntry?.release()
        camera = null
        preview = null
        textureEntry = null
        cameraProvider = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {

    }

    companion object {
        const val REQUEST_CODE = 12;
    }
}
