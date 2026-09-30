package com.eyecontrol.domain.usecase

import android.os.SystemClock
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.domain.model.DwellState
import com.eyecontrol.domain.model.ScreenPoint
import kotlin.math.hypot

class DwellController(
    private val durationMs: Long = NativeConstants.DWELL_DURATION_MS,
    private val radiusPx: Float = NativeConstants.DWELL_RADIUS_PX,
    private val onDwell: (Float, Float) -> Unit,
) {
    private var startedAt = 0L
    private var pausedAt = 0L
    private var currentDurationMs = durationMs
    private var currentRadiusPx = radiusPx
    private var anchorX = 0f
    private var anchorY = 0f
    private var cooldownUntil = 0L

    fun update(point: ScreenPoint): DwellState {
        val now = SystemClock.uptimeMillis()

        if (point.isBlinking) {
            if (startedAt != 0L && pausedAt == 0L) pausedAt = now
            return state(now, fired = false, cancelled = false)
        }

        if (pausedAt != 0L) {
            startedAt += now - pausedAt
            pausedAt = 0L
        }

        if (now < cooldownUntil) return state(now, fired = false, cancelled = false)

        val moved = startedAt != 0L &&
            hypot(point.xPx - anchorX, point.yPx - anchorY) > currentRadiusPx
        if (startedAt == 0L || moved) {
            startedAt = now
            pausedAt = 0L
            anchorX = point.xPx
            anchorY = point.yPx
            return state(now, fired = false, cancelled = moved)
        }

        val elapsed = now - startedAt
        if (elapsed >= currentDurationMs) {
            onDwell(anchorX, anchorY)
            cooldownUntil = now + COOLDOWN_MS
            resetAnchor()
            return DwellState(progress = 1f, fired = true, cancelled = false)
        }

        return state(now, fired = false, cancelled = false)
    }

    fun configure(durationMs: Long, radiusPx: Float) {
        require(durationMs in 300L..3000L)
        require(radiusPx in 20f..250f)
        currentDurationMs = durationMs
        currentRadiusPx = radiusPx
        reset()
    }

    fun reset() {
        resetAnchor()
        cooldownUntil = 0L
    }

    private fun resetAnchor() {
        startedAt = 0L
        pausedAt = 0L
    }

    private fun state(now: Long, fired: Boolean, cancelled: Boolean): DwellState {
        if (startedAt == 0L) return DwellState(0f, fired, cancelled)
        val elapsed = (now - startedAt).coerceAtLeast(0L)
        return DwellState(
            progress = (elapsed.toFloat() / currentDurationMs).coerceIn(0f, 1f),
            fired = fired,
            cancelled = cancelled,
        )
    }

    private companion object {
        const val COOLDOWN_MS = 500L
    }
}
