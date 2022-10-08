package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.m2049r.xmrwallet.model.WalletListener
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.services.NodeManager
import java.io.File

object WalletEventsChannel : EventChannel.StreamHandler, WalletListener {

    private var eventSink: EventChannel.EventSink? = null
    private const val WALLET_EVENTS = "wallet.events"
    private var lastBlockTime = 0L
    private var lastTxCount = 0
    private val scope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
    private const val TAG = "WalletEventsChannel"

    fun init(binaryMessenger: BinaryMessenger, lifecycle: Lifecycle) {
        EventChannel(binaryMessenger, WALLET_EVENTS)
            .setStreamHandler(this)
        lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    scope.cancel()
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
    }

    override fun unconfirmedMoneyReceived(txId: String?, amount: Long) {

    }

    override fun newBlock(height: Long) {
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
            Log.i(TAG, "newBlock: ${height}")
            // we want to see our transactions as they come in
            if (lastBlockTime < System.currentTimeMillis() - 2000) {
                lastBlockTime = System.currentTimeMillis()
                val currentNode = NodeManager.getNode()
                if (!wallet.isSynchronized) {
                    // we want to see our transactions as they come in
                    wallet.refreshHistory()
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
        val wallet = WalletManager.getInstance().wallet
        if (wallet != null) {
            sendEvent(wallet.walletToHashMap())
        }
    }

    override fun refreshed() {
        val wallet = WalletManager.getInstance().wallet;
        wallet.setSynchronized()
        wallet.store()
        val currentNode = NodeManager.getNode()
        if(currentNode != null){
            sendEvent(currentNode.toHashMap().apply {
                put("syncBlock", wallet.blockChainHeight)
            })
        }
        sendEvent(wallet.walletToHashMap())
    }

}
