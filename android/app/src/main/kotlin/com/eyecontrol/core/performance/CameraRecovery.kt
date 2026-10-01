package com.eyecontrol.core.performance

/** Bounded exponential retry policy for recoverable camera failures. */
class CameraRecovery(
    private val maxAttempts: Int = 3,
    private val baseDelayMs: Long = 250,
) {
    fun <T> run(operation: () -> T): T {
        var last: Throwable? = null
        for (attempt in 0 until maxAttempts) {
            try {
                return operation()
            } catch (throwable: Throwable) {
                last = throwable
                if (attempt < maxAttempts - 1) {
                    Thread.sleep(baseDelayMs * (1L shl attempt))
                }
            }
        }
        throw IllegalStateException("Camera recovery exhausted", last)
    }
}
