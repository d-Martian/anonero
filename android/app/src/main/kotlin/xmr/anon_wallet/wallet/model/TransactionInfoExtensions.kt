package xmr.anon_wallet.wallet.model

import com.m2049r.xmrwallet.model.TransactionInfo
import com.m2049r.xmrwallet.model.TransactionInfo.Direction


fun TransactionInfo.toHashMap(): HashMap<String, Any> {
    return hashMapOf(
        "address" to this.address,
        "addressIndex" to this.addressIndex,
        "amount" to this.amount,
        "accountIndex" to this.accountIndex,
        "blockheight" to this.blockheight,
        "confirmations" to this.confirmations,
        "isPending" to this.isPending,
        "timestamp" to this.timestamp,
        "isConfirmed" to this.isConfirmed,
        "paymentId" to this.paymentId,
        "hash" to this.hash,
        "notes" to this.notes,
        "displayLabel" to this.displayLabel,
        "isSpend" to (this.direction == Direction.Direction_Out) ,
        "subaddressLabel" to this.subaddressLabel,
        "fee" to this.fee,
    )
}
