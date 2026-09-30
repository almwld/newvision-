package com.eyecontrol.data.filter

import com.eyecontrol.domain.model.GazeFrame

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

    fun filter(
        rawX: Float,
        rawY: Float,
        timestampMs: Long,
        confidence: Float,
    ): Pair<Float, Float> {
        val x = euroX.filter(kalmanX.update(rawX), timestampMs)
        val y = euroY.filter(kalmanY.update(rawY), timestampMs)
        return Pair(x.coerceIn(0f, 1f), y.coerceIn(0f, 1f))
    }

    @Deprecated("Use the raw-coordinate filter overload from ProcessGazeUseCase.")
    fun filter(frame: GazeFrame): GazeFrame {
        if (frame.blinking) return frame
        val (x, y) = filter(frame.x, frame.y, frame.timestampMs, frame.confidence)
        return frame.copy(x = x, y = y)
    }
}
