package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall


class WalletMethodChannel(messenger: BinaryMessenger, lifecycle: Lifecycle) : AnonMethodChannel(messenger, CHANNEL_NAME, lifecycle) {

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "create" -> createWallet(call, result)
        }
    }

    ///TODO Create:
    private fun createWallet(call: MethodCall, result: Result) {

    }

    ///TODO: Restore
    private fun restoreWallet(call: MethodCall, result: Result) {

    }


    companion object {
        const val CHANNEL_NAME = "wallet.channel"
    }
}