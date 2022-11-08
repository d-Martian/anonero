package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.m2049r.xmrwallet.model.Wallet.ConnectionStatus
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.utils.MoneroThreadPoolExecutor
import java.io.File

object WalletEventsChannel : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private const val WALLET_EVENTS = "wallet.events"

    private var moneroHandlerThread = MoneroHandlerThread()
    private var scope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
    private const val TAG = "WalletEventsChannel"

    private var lastDaemonStatusUpdate: Long = 0
    private var daemonHeight: Long = 0
    private var connectionStatus = ConnectionStatus.ConnectionStatus_Disconnected
    private const val STATUS_UPDATE_INTERVAL: Long = 120000 // 120s (blocktime)
    var updated = true
    var initialized = false


    fun init(binaryMessenger: BinaryMessenger, lifecycle: Lifecycle) {
        EventChannel(binaryMessenger, WALLET_EVENTS)
            .setStreamHandler(this)
        lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    scope.cancel()
                }
                if (event == Lifecycle.Event.ON_RESUME) {
                    scope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
                }
            }
        })
    }

    public fun sendEvent(hashMap: HashMap<String, Any>) {
        scope.launch {
            withContext(Dispatchers.Main) {
                eventSink?.success(hashMap)
            }
        }
    }

    public fun sendErrorEvent(errorCode: String, error: String) {
        scope.launch {
            withContext(Dispatchers.Main) {
                eventSink?.error(errorCode, error, error)
            }
        }
    }

    fun initWalletListeners() {
        val dispatcher = MoneroThreadPoolExecutor.MONERO_THREAD_POOL_EXECUTOR?.asCoroutineDispatcher() ?: Dispatchers.Unconfined
        this.scope.launch {
            withContext(dispatcher) {
                WalletManager.getInstance().wallet?.setListener(moneroHandlerThread)
                WalletManager.getInstance().wallet?.refresh()
                WalletManager.getInstance().wallet?.startRefresh()
            }
        }

    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        checkWalletState()
    }

    override fun onCancel(arguments: Any?) {
    }

    private fun checkWalletState() {
        val cacheFile = File(AnonWallet.walletDir, "default")
        val keysFile = File(AnonWallet.walletDir, "default.keys")
        val addressFile = File(AnonWallet.walletDir, "default.address.txt")
        if (cacheFile.exists() && keysFile.exists() && addressFile.exists()) {
            eventSink?.success("WALLET_EXIST")
        } else {
            eventSink?.error("0", "WALLET_NOT_INIT", null)
        }
    }

}
