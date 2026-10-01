package com.eyecontrol.data.filter

import kotlin.math.max

class KalmanFilter1D(
    private val processNoise: Float = 0.01f,
    private val measurementNoise: Float = 0.05f,
) {
    private var estimate = 0f
    private var covariance = 1f
    private var initialized = false

    fun reset() {
        estimate = 0f
        covariance = 1f
        initialized = false
    }

    fun update(measurement: Float): Float {
        if (!initialized) {
            estimate = measurement
            initialized = true
            return measurement
        }
        covariance += processNoise
        val gain = covariance / max(covariance + measurementNoise, 1e-6f)
        estimate += gain * (measurement - estimate)
        covariance *= 1f - gain
        return estimate
    }
}
