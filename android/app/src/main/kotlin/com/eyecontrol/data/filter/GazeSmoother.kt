package com.eyecontrol.data.filter

import com.eyecontrol.domain.model.EyeFeatures
import com.eyecontrol.domain.model.GazeFrame

class GazeSmoother {
    private val kalmanX = KalmanFilter1D()
    private val kalmanY = KalmanFilter1D()
    private val euroX = OneEuroFilter(minCutoff = 1.0f, beta = 0.02f)
    private val euroY = OneEuroFilter(minCutoff = 1.0f, beta = 0.02f)

    private val featureKalman = Array(4) { KalmanFilter1D() }
    private val featureEuro = Array(4) { OneEuroFilter(minCutoff = 1.0f, beta = 0.02f) }

    fun reset() {
        kalmanX.reset()
        kalmanY.reset()
        euroX.reset()
        euroY.reset()
        featureKalman.forEach(KalmanFilter1D::reset)
        featureEuro.forEach(OneEuroFilter::reset)
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

    fun filterEyeFeatures(features: EyeFeatures, timestampMs: Long): EyeFeatures {
        val input = features.toFloatArray()
        val output = FloatArray(4)
        for (i in input.indices) {
            output[i] = featureEuro[i].filter(
                featureKalman[i].update(input[i]),
                timestampMs,
            )
        }
        return EyeFeatures(output[0], output[1], output[2], output[3])
    }

    @Deprecated("Use the raw-coordinate filter overload from ProcessGazeUseCase.")
    fun filter(frame: GazeFrame): GazeFrame {
        if (frame.blinking) return frame
        val (x, y) = filter(frame.x, frame.y, frame.timestampMs, frame.confidence)
        return frame.copy(x = x, y = y)
    }
}
