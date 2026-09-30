package com.eyecontrol.data.decision

import com.eyecontrol.domain.model.ScreenPoint
import kotlin.math.hypot

enum class GazeIntent {
    FIXATION,
    SACCADE,
    SMOOTH_PURSUIT,
}

class IntentDetector(
    private val fixationSpeedPxPerSecond: Float = 80f,
    private val saccadeSpeedPxPerSecond: Float = 1200f,
) {
    private var previous: ScreenPoint? = null

    fun detect(point: ScreenPoint): GazeIntent {
        val old = previous
        previous = point
        if (old == null || point.isBlinking || point.timestampNs <= old.timestampNs) {
            return GazeIntent.FIXATION
        }
        val deltaSeconds = (point.timestampNs - old.timestampNs) / 1_000_000_000f
        if (deltaSeconds <= 0f) return GazeIntent.FIXATION
        val speed = hypot(point.xPx - old.xPx, point.yPx - old.yPx) / deltaSeconds
        return when {
            speed <= fixationSpeedPxPerSecond -> GazeIntent.FIXATION
            speed >= saccadeSpeedPxPerSecond -> GazeIntent.SACCADE
            else -> GazeIntent.SMOOTH_PURSUIT
        }
    }

    fun reset() {
        previous = null
    }
}
