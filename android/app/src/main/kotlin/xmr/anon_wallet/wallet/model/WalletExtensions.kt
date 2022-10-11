package xmr.anon_wallet.wallet.model

import android.util.Log
import com.m2049r.xmrwallet.data.Subaddress
import com.m2049r.xmrwallet.model.Wallet

fun Wallet.getLastSubAddressIndex(): Int {
    //index starts from 1 to ignore primary 0 address
    var lastUsedSubaddress = 0
    for (info in this.history.all) {
        if (info.addressIndex > lastUsedSubaddress) lastUsedSubaddress = info.addressIndex
    }
    return lastUsedSubaddress;
}

fun Wallet.getLatestSubaddress(): Subaddress? {
    var lastUsedSubaddress = getLastSubAddressIndex()
    lastUsedSubaddress++
    val address = this.getSubaddressObject(lastUsedSubaddress);
    if ( lastUsedSubaddress == this.numSubaddresses) {
        this.addSubaddress(accountIndex, "Subaddress #${address.addressIndex}")
    }
    return address
}

fun Subaddress.toHashMap(): HashMap<String, Any> {
    return hashMapOf(
        "address" to (this.address ?: ""),
        "addressIndex" to this.addressIndex,
        "accountIndex" to this.accountIndex,
        "displayLabel" to (this.displayLabel ?: ""),
        "label" to (this.label ?: ""),
        "totalAmount" to (this.totalAmount),
        "squashedAddress" to this.squashedAddress,
    );
}

fun Wallet.walletToHashMap(): HashMap<String, Any> {
    val nextAddress = if (this.getLatestSubaddress() != null) this.getLatestSubaddress()?.toHashMap()!! else hashMapOf<String, String>()
    return hashMapOf(
        "name" to this.name,
        "address" to this.address,
        "secretViewKey" to this.secretViewKey,
        "balance" to this.balance,
        "currentAddress" to nextAddress,
        "isSynchronized" to this.isSynchronized,
        "blockChainHeight" to this.blockChainHeight,
        "numSubaddresses" to this.numSubaddresses,
        "seedLanguage" to this.seedLanguage,
        "restoreHeight" to this.restoreHeight,
        "transactions" to this.history.all.map { it.toHashMap() }.reversed().toList(),
        "EVENT_TYPE" to "WALLET",
    )
}
