package xmr.anon_wallet.wallet.utils

import java.util.concurrent.*
import java.util.concurrent.atomic.AtomicInteger

object MoneroThreadPoolExecutor {
    const val THREAD_STACK_SIZE = (5 * 1024 * 1024).toLong()
    var MONERO_THREAD_POOL_EXECUTOR: Executor? = null
    private val CPU_COUNT = Runtime.getRuntime().availableProcessors()
    private val CORE_POOL_SIZE = 2.coerceAtLeast((CPU_COUNT - 1).coerceAtMost(4))
    private val MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1
    private const val KEEP_ALIVE_SECONDS = 30L
    private val sThreadFactory: ThreadFactory = object : ThreadFactory {
        private val mCount = AtomicInteger(1)
        override fun newThread(r: Runnable): Thread {
            return Thread(null, r, "MoneroTask #" + mCount.getAndIncrement(), THREAD_STACK_SIZE)
        }
    }
    private val sPoolWorkQueue: BlockingQueue<Runnable> = LinkedBlockingQueue(128)

    init {
        val threadPoolExecutor: ThreadPoolExecutor = ThreadPoolExecutor(
            CORE_POOL_SIZE,
            MAXIMUM_POOL_SIZE,
            KEEP_ALIVE_SECONDS,
            TimeUnit.SECONDS,
            sPoolWorkQueue,
            sThreadFactory
        )
        threadPoolExecutor.allowCoreThreadTimeOut(true)
        MONERO_THREAD_POOL_EXECUTOR = threadPoolExecutor
    }
}