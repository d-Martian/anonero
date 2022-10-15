package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.Wallet.ConnectionStatus
import com.m2049r.xmrwallet.model.WalletListener
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import java.io.File

object WalletEventsChannel : EventChannel.StreamHandler, WalletListener {

    private var eventSink: EventChannel.EventSink? = null
    private const val WALLET_EVENTS = "wallet.events"
    private var lastBlockTime = 0L
    private var lastTxCount = 0
    private var scope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
    private const val TAG = "WalletEventsChannel"


    private var lastDaemonStatusUpdate: Long = 0
    private var daemonHeight: Long = 0
    private var connectionStatus = ConnectionStatus.ConnectionStatus_Disconnected
    private const val STATUS_UPDATE_INTERVAL: Long = 120000 // 120s (blocktime)
    var updated = true


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

    fun initWalletRefresh() {
        WalletManager.getInstance().wallet?.let {
            lastBlockTime = 0L
            it.startRefresh()
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

    override fun moneySpent(txId: String?, amount: Long) {

    }

    override fun moneyReceived(txId: String?, amount: Long) {
        Log.i(TAG, "moneyReceived: $txId $amount")
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
             sendEvent(wallet.walletToHashMap())
        }
    }

    override fun unconfirmedMoneyReceived(txId: String?, amount: Long) {
        WalletManager.getInstance().wallet.let {
        }
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
            wallet.refreshHistory()
            sendEvent(wallet.walletToHashMap())
        }
    }

    override fun newBlock(height: Long) {
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
            // we want to see our transactions as they come in
            updateDaemonState(wallet, if (wallet.isSynchronized) height else 0)
            if (lastBlockTime < System.currentTimeMillis() - 2000) {
                Log.i(TAG, "newBlock: ${height}")
                lastBlockTime = System.currentTimeMillis()
                val currentNode = NodeManager.getNode()
                if (!wallet.isSynchronized) {
                    // we want to see our transactions as they come in
                    wallet.refreshHistory()
                    val txCount = wallet.history.count
                    if (txCount > lastTxCount) {
                        // update the transaction list only if we have more than before
                        lastTxCount = txCount
                    }
                }
                if (currentNode != null) {
                    sendEvent(currentNode.toHashMap().apply {
                        put("syncBlock", height)
                    })
                }
            }

        }

    }

    override fun updated() {
        Log.i(TAG, "updated:")
        val wallet = WalletManager.getInstance().wallet
        if (wallet != null) {
            sendEvent(wallet.walletToHashMap())
        }
        updated = true

    }

    override fun refreshed() {
        val wallet = WalletManager.getInstance().wallet;
        wallet.setSynchronized()
        wallet.store()
        val currentNode = NodeManager.getNode()
        if (currentNode != null) {
            sendEvent(currentNode.toHashMap().apply {
                put("syncBlock", wallet.blockChainHeight)
            })
        }
        wallet.refreshHistory()
        sendEvent(wallet.walletToHashMap())
        updateDaemonState(wallet, wallet.blockChainHeight)
    }

    private fun updateDaemonState(wallet: Wallet, height: Long) {
        val t = System.currentTimeMillis()
        if (height > 0) { // if we get a height, we are connected
            daemonHeight = height
            connectionStatus = Wallet.ConnectionStatus.ConnectionStatus_Connected
            lastDaemonStatusUpdate = t
        } else {
            if (t - lastDaemonStatusUpdate > STATUS_UPDATE_INTERVAL) {
                lastDaemonStatusUpdate = t
                // these calls really connect to the daemon - wasting time
                daemonHeight = wallet.daemonBlockChainHeight
                if (daemonHeight > 0) {
                    // if we get a valid height, then obviously we are connected
                    connectionStatus = Wallet.ConnectionStatus.ConnectionStatus_Connected
                } else {
                    connectionStatus = Wallet.ConnectionStatus.ConnectionStatus_Disconnected
                }
            }
        }
    }
}
