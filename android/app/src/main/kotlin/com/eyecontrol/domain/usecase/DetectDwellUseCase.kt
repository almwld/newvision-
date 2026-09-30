package com.eyecontrol.domain.usecase

import android.os.SystemClock
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.data.decision.GazeIntent
import com.eyecontrol.data.decision.IntentDetector
import com.eyecontrol.domain.model.DwellState
import com.eyecontrol.domain.model.ScreenPoint
import kotlin.math.hypot

class DetectDwellUseCase(
    private val onDwell: (Float, Float) -> Unit,
    private val intentDetector: IntentDetector = IntentDetector(),
) {
    private var durationMs = NativeConstants.DWELL_DURATION_MS
    private var radiusPx = NativeConstants.DWELL_RADIUS_PX
    private var startedAt = 0L
    private var pausedAt = 0L
    private var cooldownUntil = 0L
    private var anchorX = 0f
    private var anchorY = 0f

    fun update(point: ScreenPoint): DwellState {
        val now = SystemClock.uptimeMillis()
        val intent = intentDetector.detect(point)

        if (point.isBlinking) {
            if (startedAt != 0L && pausedAt == 0L) pausedAt = now
            return state(now, false, false)
        }

        if (pausedAt != 0L) {
            startedAt += now - pausedAt
            pausedAt = 0L
        }

        if (now < cooldownUntil) return state(now, false, false)
        if (intent != GazeIntent.FIXATION) {
            if (intent == GazeIntent.SACCADE) {
                resetAnchor()
                return DwellState(0f, false, true)
            }
            return state(now, false, false)
        }

        val moved = startedAt != 0L &&
            hypot(point.xPx - anchorX, point.yPx - anchorY) > radiusPx
        if (startedAt == 0L || moved) {
            startedAt = now
            anchorX = point.xPx
            anchorY = point.yPx
            return DwellState(0f, false, moved)
        }

        val elapsed = now - startedAt
        if (elapsed >= durationMs) {
            onDwell(anchorX, anchorY)
            cooldownUntil = now + 500L
            resetAnchor()
            return DwellState(1f, true, false)
        }
        return state(now, false, false)
    }

    fun configure(durationMs: Long, radiusPx: Float) {
        require(durationMs in 300L..3000L)
        require(radiusPx in 20f..250f)
        this.durationMs = durationMs
        this.radiusPx = radiusPx
        reset()
    }

    fun reset() {
        resetAnchor()
        cooldownUntil = 0L
        intentDetector.reset()
    }

    private fun resetAnchor() {
        startedAt = 0L
        pausedAt = 0L
    }

    private fun state(now: Long, fired: Boolean, cancelled: Boolean): DwellState {
        if (startedAt == 0L) return DwellState(0f, fired, cancelled)
        val elapsed = (now - startedAt).coerceAtLeast(0L)
        return DwellState(
            (elapsed.toFloat() / durationMs).coerceIn(0f, 1f),
            fired,
            cancelled,
        )
    }
}
