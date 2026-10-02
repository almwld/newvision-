package com.eyecontrol.data.decision

import com.eyecontrol.domain.model.ScreenPoint
import kotlin.math.hypot

enum class GazeIntent {
    FIXATION,
    SACCADE,
    SMOOTH_PURSUIT,
}

/**
 * Converts consecutive valid screen points into a stable gaze intent.
 *
 * Blink frames and out-of-order timestamps never replace the last valid sample.
 * This keeps a blink from creating a false saccade when tracking resumes.
 */
class IntentDetector(
    private val fixationSpeedPxPerSecond: Float = 80f,
    private val saccadeSpeedPxPerSecond: Float = 1200f,
) {
    private var previous: ScreenPoint? = null

    init {
        require(fixationSpeedPxPerSecond >= 0f)
        require(saccadeSpeedPxPerSecond > fixationSpeedPxPerSecond)
    }

    fun detect(point: ScreenPoint): GazeIntent {
        if (point.isBlinking) return GazeIntent.FIXATION

        val old = previous
        if (old == null) {
            previous = point
            return GazeIntent.FIXATION
        }

        if (point.timestampNs <= old.timestampNs) return GazeIntent.FIXATION

        val deltaSeconds = (point.timestampNs - old.timestampNs) / 1_000_000_000f
        if (deltaSeconds <= 0f) return GazeIntent.FIXATION

        val speed = hypot(point.xPx - old.xPx, point.yPx - old.yPx) / deltaSeconds
        previous = point

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
