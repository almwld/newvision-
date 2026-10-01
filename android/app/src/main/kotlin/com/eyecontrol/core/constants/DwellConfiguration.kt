package com.eyecontrol.core.constants

import java.util.concurrent.atomic.AtomicLong
import java.util.concurrent.atomic.AtomicReference

/**
 * Process-local dwell settings shared by the native interaction layer.
 */
object DwellConfiguration {
    private val duration = AtomicLong(NativeConstants.DWELL_DURATION_MS)
    private val radius = AtomicReference(NativeConstants.DWELL_RADIUS_PX)

    fun configure(durationMs: Long, radiusPx: Float) {
        require(durationMs in 300L..3000L) { "Dwell duration must be between 300 and 3000 ms." }
        require(radiusPx in 20f..250f) { "Dwell radius must be between 20 and 250 px." }
        duration.set(durationMs)
        radius.set(radiusPx)
    }

    fun durationMs(): Long = duration.get()
    fun radiusPx(): Float = radius.get()
}
