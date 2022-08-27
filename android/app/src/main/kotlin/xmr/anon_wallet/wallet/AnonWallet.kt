package xmr.anon_wallet.wallet

import com.m2049r.xmrwallet.model.NetworkType

object AnonWallet {

    fun getNetworkType(): NetworkType {
        return NetworkType.NetworkType_Testnet
    }
}