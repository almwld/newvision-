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
    private var currentDurationMs = durationMs
    private var currentRadiusPx = radiusPx
    private var anchorX = 0f
    private var anchorY = 0f

    fun update(frame: GazeFrame) {
        if (frame.blinking) {
            reset()
            return
        }
        if (startedAt == 0L || hypot(frame.x - anchorX, frame.y - anchorY) > currentRadiusPx) {
            startedAt = SystemClock.uptimeMillis()
            anchorX = frame.x
            anchorY = frame.y
            return
        }
        if (SystemClock.uptimeMillis() - startedAt >= currentDurationMs) {
            onDwell(anchorX, anchorY)
            reset()
        }
    }

    fun configure(durationMs: Long, radiusPx: Float) {
        require(durationMs in 300L..3000L)
        require(radiusPx in 20f..250f)
        currentDurationMs = durationMs
        currentRadiusPx = radiusPx
        reset()
    }

    fun reset() {
        startedAt = 0L
    }
}
