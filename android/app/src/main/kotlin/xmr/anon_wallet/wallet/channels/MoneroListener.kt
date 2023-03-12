package xmr.anon_wallet.wallet.channels

import android.app.NotificationManager
import androidx.core.app.NotificationCompat
import anon.xmr.app.anon_wallet.R
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletListener
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.channels.WalletEventsChannel.sendEvent
import xmr.anon_wallet.wallet.model.walletToHashMap
import xmr.anon_wallet.wallet.services.NodeManager
import java.text.NumberFormat

//
//// from src/cryptonote_config.h
//val THREAD_STACK_SIZE = (5 * 1024 * 1024).toLong()

class MoneroHandlerThread : WalletListener {
    private var lastBlockTime = 0L
    private var lastTxCount = 0
    private var walletFirstBlock: Long? = null

    private var lastDaemonStatusUpdate: Long = 0
    private var daemonHeight: Long = 0
    private var connectionStatus = Wallet.ConnectionStatus.ConnectionStatus_Disconnected
    var updated = true

    override fun moneySpent(txId: String?, amount: Long) {

    }

    override fun moneyReceived(txId: String?, amount: Long) {
        val wallet = WalletManager.getInstance().wallet
        if (wallet != null) {
            sendEvent(wallet.walletToHashMap())
        }
    }


    override fun unconfirmedMoneyReceived(txId: String?, amount: Long) {
        showNotification(txId, amount)
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
            wallet.refreshHistory()
            sendEvent(AddressMethodChannel.getSubAddressesEvent())
            sendEvent(wallet.walletToHashMap())
        }
    }

    @Synchronized
    override fun newBlock(height: Long) {
        val wallet = WalletManager.getInstance().wallet;
        if (wallet != null) {
            // we want to see our transactions as they come in
            updateDaemonState(wallet, if (wallet.isSynchronized) height else 0)
            if (lastBlockTime < System.currentTimeMillis() - 2000) {
                lastBlockTime = System.currentTimeMillis()
                val currentNode = NodeManager.getNode()
                if (!wallet.isSynchronized) {
                    // we want to see our transactions as they come in
                    val txCount = wallet.history.count
                    if (txCount > lastTxCount) {
                        // update the transaction list only if we have more than before
                        lastTxCount = txCount
                    }
                }
                if (currentNode != null && !wallet.isSynchronized) {
                    val daemonHeight: Long = WalletManager.getInstance().blockchainHeight
                    val walletHeight = wallet.blockChainHeight
                    val n = daemonHeight - walletHeight
                    if (walletFirstBlock == null) {
                        walletFirstBlock = walletHeight
                    }
                    val progress = 1 - (n / (1f * daemonHeight - walletFirstBlock!!))
                    val percentage = if (progress < 0.1f) {
                        0.1f
                    } else {
                        progress
                    }
                    sendEvent(currentNode.toHashMap().apply {
                        put("syncBlock", height)
                        put("remainingBlocks", daemonHeight - height)
                        put("syncPercentage", percentage)
                    })
                } else {
                    walletFirstBlock = null
                }
            }

        }

    }

    override fun updated() {
        val wallet = WalletManager.getInstance().wallet
        wallet.refreshHistory()
        if (wallet != null) {
            sendEvent(wallet.walletToHashMap())
        }
        updated = true
    }

    override fun refreshed() {

        val wallet = WalletManager.getInstance().wallet;
        val currentNode = NodeManager.getNode()
        if (currentNode != null && !wallet.isSynchronized ) {
            sendEvent(currentNode.toHashMap().apply {
                put("syncBlock", wallet.blockChainHeight)
            })
        }
        walletFirstBlock = null
        wallet.refreshHistory()
        sendEvent(wallet.walletToHashMap())
        sendEvent(AddressMethodChannel.getSubAddressesEvent())
        updateDaemonState(wallet, wallet.blockChainHeight)
        wallet.setSynchronized()
        wallet.store()
    }

    private fun updateDaemonState(wallet: Wallet, height: Long) {
        val t = System.currentTimeMillis()
        if (height > 0) { // if we get a height, we are connected
            daemonHeight = height
            connectionStatus = Wallet.ConnectionStatus.ConnectionStatus_Connected
            lastDaemonStatusUpdate = t
        } else {
            if (t - lastDaemonStatusUpdate > Companion.STATUS_UPDATE_INTERVAL) {
                lastDaemonStatusUpdate = t
                // these calls really connect to the daemon - wasting time
                daemonHeight = wallet.daemonBlockChainHeight
                connectionStatus = if (daemonHeight > 0) {
                    // if we get a valid height, then obviously we are connected
                    Wallet.ConnectionStatus.ConnectionStatus_Connected
                } else {
                    Wallet.ConnectionStatus.ConnectionStatus_Disconnected
                }
            }
        }
    }

    companion object {
        private const val TAG = "MoneroHandlerThread"
        private const val STATUS_UPDATE_INTERVAL: Long = 120000 // 120s (blocktime)
    }


    private fun showNotification(txId: String?, amount: Long) {
        val nf = NumberFormat.getInstance()
        nf.maximumFractionDigits = 4
        nf.minimumFractionDigits = 4
        val amountText = nf.format((amount / 1e12));
        GlobalScope.launch {
            withContext(Dispatchers.Main) {
                try {
                    val notificationBuilder: NotificationCompat.Builder = NotificationCompat.Builder(AnonWallet.getAppContext(), AnonWallet.NOTIFICATION_CHANNEL_ID)
                    val notification = notificationBuilder.setAutoCancel(false)
                        .setWhen(System.currentTimeMillis())
                        .setSmallIcon(R.drawable.anon_mono)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setTicker("Received $amountText")
                        .setContentTitle("Received new transaction")
                        .setContentText("Amount : ${amountText} xmr")
                        .build()
                    val mNotificationManager = AnonWallet.getAppContext().getSystemService(FlutterActivity.NOTIFICATION_SERVICE) as NotificationManager
                    mNotificationManager.notify(12, notification)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }

    }

}