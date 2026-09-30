package com.eyecontrol.data.filter

import com.eyecontrol.domain.model.GazeFrame

/**
 * Applies a lightweight Kalman pass followed by adaptive One-Euro smoothing.
 */
class GazeSmoother {
    private val kalmanX = KalmanFilter1D()
    private val kalmanY = KalmanFilter1D()
    private val euroX = OneEuroFilter(minCutoff = 1.0f, beta = 0.02f)
    private val euroY = OneEuroFilter(minCutoff = 1.0f, beta = 0.02f)

    fun reset() {
        kalmanX.reset()
        kalmanY.reset()
        euroX.reset()
        euroY.reset()
    }

    fun filter(frame: GazeFrame): GazeFrame {
        if (frame.blinking || frame.confidence < 0.25f) return frame
        val x = euroX.filter(kalmanX.update(frame.x), frame.timestampMs)
        val y = euroY.filter(kalmanY.update(frame.y), frame.timestampMs)
        return frame.copy(
            x = x.coerceIn(0f, 1f),
            y = y.coerceIn(0f, 1f),
        )
    }
}
