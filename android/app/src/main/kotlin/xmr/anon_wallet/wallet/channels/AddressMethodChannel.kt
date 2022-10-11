package xmr.anon_wallet.wallet.channels

import android.util.Log
import androidx.lifecycle.Lifecycle
import com.m2049r.xmrwallet.data.Subaddress
import com.m2049r.xmrwallet.model.WalletManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xmr.anon_wallet.wallet.model.getLatestSubaddress
import xmr.anon_wallet.wallet.model.toHashMap
import xmr.anon_wallet.wallet.model.walletToHashMap

class AddressMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) :
    AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {


    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "renameAddress" -> renameAddress(call, result)
            "getSubAddresses" -> getSubAddresses(result)
        }
    }

    private fun getSubAddresses(result: Result) {
        WalletEventsChannel.sendEvent(getSubAddressesEvent())
        result.success(null);
    }

    private fun renameAddress(call: MethodCall, result: Result) {
        val wallet = WalletManager.getInstance().wallet
        if (wallet != null) {
            val label = call.argument<String>("label")
            val addressIndex = call.argument<Int>("addressIndex")
            val accountIndex = call.argument<Int>("accountIndex")
            if (label == null || addressIndex == null || accountIndex == null) {
                result.error("invalid arg", "invalid method call params", null);
            }
            scope.launch {
                withContext(Dispatchers.IO) {
                    wallet.setSubaddressLabel(
                        addressIndex!!,
                        label
                    )
                    wallet.refreshHistory()
                    wallet.store()
                    WalletEventsChannel.sendEvent(wallet.walletToHashMap())
                    WalletEventsChannel.sendEvent(getSubAddressesEvent())
                }
            }
        }
    }

    companion object {
        const val CHANNEL_NAME = "address.channel"
        public fun getSubAddressesEvent(): HashMap<String, Any> {
            return hashMapOf(
                "EVENT_TYPE" to "SUB_ADDRESSES",
                "addresses" to getAllSubAddresses().map { it.toHashMap() }.toList()
            )
        }
        private fun getAllSubAddresses(): List<Subaddress> {
            val wallet = WalletManager.getInstance().wallet
            val subaddrs = arrayListOf<Subaddress>()
            wallet.getLatestSubaddress()?.let {
                subaddrs.add(it)
            }
            if (wallet != null) {
                for (info in wallet.history.all) {
                    val address = wallet.getSubaddressObject(info.addressIndex)
                    val existItem = (subaddrs.find { it.address == address.address });
                    if (existItem != null) {
                        existItem.setAmount(existItem.totalAmount + info.amount)
                    } else {
                        subaddrs.add(address.apply { setAmount(info.amount) })
                    }
                }
            }
            return subaddrs;
        }
    }
}