package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.model.PendingTransaction
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.AnonWallet.ONE_XMR

class SpendMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "validate" -> validate(call, result)
            "composeTransaction" -> composeTransaction(call, result)
            "composeAndBroadcast" -> composeAndBroadcast(call, result)
        }
    }

    private fun composeAndBroadcast(call: MethodCall, result: Result) {
        val address = call.argument<String?>("address")
        val amount = call.argument<String>("amount")
        val notes = call.argument<String>("notes")
        val amountNumeric = Wallet.getAmountFromString(amount)
        if (address == null || amount == null) {
            return result.error("1", "invalid args", null)
        }
        this.scope.launch {
            withContext(Dispatchers.IO) {
                val wallet = WalletManager.getInstance().wallet
                val pendingTx = wallet.createTransaction(address, amountNumeric, 1, PendingTransaction.Priority.Priority_Default);
                val txId = pendingTx.firstTxIdJ;
                var error = "";
                var success = false;
                try {
                    success = pendingTx.commit("", true)
                    if (success) {
                        wallet.refreshHistory()
                        wallet.setUserNote(txId, notes)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    error = e.message ?: "";
                }

                wallet.store()
                withContext(Dispatchers.IO) {
                    result.success(
                        hashMapOf(
                            "fee" to pendingTx.fee,
                            "amount" to pendingTx.amount,
                            "state" to if (success) "success" else "error",
                            "status" to pendingTx.status.toString(),
                            "txId" to (txId ?: ""),
                            "txCount" to pendingTx.txCount,
                            "errorString" to error.ifEmpty { pendingTx.errorString },
                        )
                    )
                }
            }
        }
    }

    private fun composeTransaction(call: MethodCall, result: Result) {
        val address = call.argument<String?>("address")
        val amount = call.argument<String>("amount")
        val notes = call.argument<String>("notes")
        val amountNumeric = Wallet.getAmountFromString(amount)
        if (address == null || amount == null) {
            return result.error("1", "invalid args", null)
        }
        this.scope.launch {
            withContext(Dispatchers.IO) {
                try {
                    val wallet = WalletManager.getInstance().wallet
                    val pendingTx = wallet.createTransaction(address, amountNumeric, 1, PendingTransaction.Priority.Priority_Default)
                    result.success(
                        hashMapOf(
                            "fee" to pendingTx.fee,
                            "amount" to pendingTx.amount,
                            "state" to "preview",
                            "status" to pendingTx.status.toString(),
                            "txId" to (pendingTx.firstTxIdJ ?: ""),
                            "txCount" to pendingTx.txCount,
                            "errorString" to pendingTx.errorString,
                        )
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun validate(call: MethodCall, result: Result) {
        val address = call.argument<String?>("address")
        val amount = call.argument<String>("amount")
        val wallet = WalletManager.getInstance().wallet
        val funds = wallet.unlockedBalance
        val maxFunds = 1.0 * funds / ONE_XMR
        val amountNumeric = Wallet.getAmountFromString(amount)
        val response = try {
            hashMapOf(
                "address" to Wallet.isAddressValid(address),
                "amount" to (amountNumeric < 0 || amountNumeric > maxFunds)
            )
        } catch (e: Exception) {
            return result.error("0", e.cause?.message, e.message)
        }
        return result.success(response)
    }

    companion object {
        const val CHANNEL_NAME = "spend.channel"
    }

}