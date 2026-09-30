package com.eyecontrol.domain.usecase

import android.os.SystemClock
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.domain.model.GazeFrame
import kotlin.math.hypot

class DwellController(
    private val durationMs: Long = NativeConstants.DWELL_DURATION_MS,
    private val radiusPx: Float = NativeConstants.DWELL_RADIUS_PX,
    private val onDwell: (Float, Float) -> Unit,
) {
    private var startedAt = 0L
    private var anchorX = 0f
    private var anchorY = 0f

    fun update(frame: GazeFrame) {
        if (frame.blinking) {
            reset()
            return
        }
        if (startedAt == 0L || hypot(frame.x - anchorX, frame.y - anchorY) > radiusPx) {
            startedAt = SystemClock.uptimeMillis()
            anchorX = frame.x
            anchorY = frame.y
            return
        }
        if (SystemClock.uptimeMillis() - startedAt >= durationMs) {
            onDwell(anchorX, anchorY)
            reset()
        }
    }

    fun reset() {
        startedAt = 0L
    }
}
