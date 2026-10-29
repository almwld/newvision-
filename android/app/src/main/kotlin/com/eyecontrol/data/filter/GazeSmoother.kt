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

    // L2CS outputs degrees, not normalized screen coordinates. Keep an independent
    // EMA so the normalized-coordinate clamp in filter() can never flatten angles.
    private var smoothedYaw: Float? = null
    private var smoothedPitch: Float? = null
    private var lastAngleTimestampMs = Long.MIN_VALUE
    private val angleAlpha = 0.32f

    fun reset() {
        kalmanX.reset()
        kalmanY.reset()
        euroX.reset()
        euroY.reset()
        featureKalman.forEach(KalmanFilter1D::reset)
        featureEuro.forEach(OneEuroFilter::reset)
        smoothedYaw = null
        smoothedPitch = null
        lastAngleTimestampMs = Long.MIN_VALUE
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

    fun filterAngles(yawDegrees: Float, pitchDegrees: Float, timestampMs: Long): Pair<Float, Float> {
        val previousYaw = smoothedYaw
        val previousPitch = smoothedPitch
        if (!yawDegrees.isFinite() || !pitchDegrees.isFinite()) {
            return Pair(previousYaw ?: 0f, previousPitch ?: 0f)
        }
        if (timestampMs <= lastAngleTimestampMs && previousYaw != null && previousPitch != null) {
            return Pair(previousYaw, previousPitch)
        }
        val yaw = yawDegrees.coerceIn(-180f, 180f)
        val pitch = pitchDegrees.coerceIn(-180f, 180f)
        smoothedYaw = previousYaw?.let { it + angleAlpha * (yaw - it) } ?: yaw
        smoothedPitch = previousPitch?.let { it + angleAlpha * (pitch - it) } ?: pitch
        lastAngleTimestampMs = timestampMs
        return Pair(smoothedYaw!!, smoothedPitch!!)
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
