package xmr.anon_wallet.wallet.channels

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

/**
 * Method channel abstract that supports activity life cycle
 * Coroutine scope support for asynchronous tasks
 */
abstract class AnonMethodChannel(messenger: BinaryMessenger, name: String, lifecycle: Lifecycle) : MethodChannel(messenger, name),
    MethodChannel.MethodCallHandler, DefaultLifecycleObserver {

    private val _mainScope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()

    val scope: CoroutineScope
        get() = _mainScope

    init {
        lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_CREATE) {
                    setMethodCallHandler(this@AnonMethodChannel)
                }
                if (event == Lifecycle.Event.ON_DESTROY) {
                    onClear()
                }
            }
        })
    }

    //Implemented in child class
    override fun onMethodCall(call: MethodCall, result: Result) {
        //NO-OP
    }

    fun onClear() {
        _mainScope.cancel()
    }

    companion object{
        const val INVALID_ARG = "er_arg"
        const val ERRORS = "er_process"
        const val WALLET_EXIST = "wallet_exist"
    }
}