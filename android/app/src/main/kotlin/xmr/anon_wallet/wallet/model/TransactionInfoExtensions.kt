package xmr.anon_wallet.wallet.model

import com.m2049r.xmrwallet.data.Subaddress
import com.m2049r.xmrwallet.model.TransactionInfo
import com.m2049r.xmrwallet.model.TransactionInfo.Direction
import com.m2049r.xmrwallet.model.Transfer
import com.m2049r.xmrwallet.model.Wallet
import com.m2049r.xmrwallet.model.WalletManager


fun TransactionInfo.toHashMap(): HashMap<String, Any> {
    val wallet: Wallet? = WalletManager.getInstance().wallet

    val subaddress:Subaddress? = wallet?.getSubaddressObject(this.accountIndex,this.addressIndex)
    return hashMapOf(
        "address" to this.address,
        "addressIndex" to this.addressIndex,
        "amount" to this.amount,
        "accountIndex" to this.accountIndex,
        "blockheight" to (this.blockheight ?:  "-"),
        "confirmations" to this.confirmations,
        "isPending" to this.isPending,
        "timestamp" to this.timestamp,
        "isConfirmed" to this.isConfirmed,
        "paymentId" to this.paymentId,
        "txKey" to if (wallet != null) wallet.getTxKey(this.hash) else "",
        "hash" to this.hash,
        "notes" to this.notes,
        "displayLabel" to this.displayLabel,
        "isSpend" to (this.direction == Direction.Direction_Out),
        "subaddressLabel" to this.subaddressLabel,
        "addressDetail" to (subaddress?.toHashMap() ?: ""),
        "transfers" to if (this.transfers != null) this.transfers.map { it.toHashMap() }.toList() else listOf(),
        "fee" to this.fee,
    )
}

fun Transfer.toHashMap(): HashMap<String, Any> {
    return hashMapOf(
        "amount" to this.amount,
        "address" to this.address,
    )
}