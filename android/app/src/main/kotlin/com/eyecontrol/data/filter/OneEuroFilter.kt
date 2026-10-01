package com.eyecontrol.data.filter

import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sqrt

class OneEuroFilter(
    private val minCutoff: Float = 1f,
    private val beta: Float = 0.01f,
    private val derivativeCutoff: Float = 1f,
) {
    private var previousTimestamp = Long.MIN_VALUE
    private var previousValue = 0f
    private var previousDerivative = 0f

    fun reset() {
        previousTimestamp = Long.MIN_VALUE
        previousValue = 0f
        previousDerivative = 0f
    }

    fun filter(value: Float, timestampMs: Long): Float {
        if (previousTimestamp == Long.MIN_VALUE) {
            previousTimestamp = timestampMs
            previousValue = value
            return value
        }
        val deltaSeconds = ((timestampMs - previousTimestamp).coerceAtLeast(1L)) / 1000f
        previousTimestamp = timestampMs

        val rawDerivative = (value - previousValue) / deltaSeconds
        previousDerivative = lowPass(
            previousDerivative,
            rawDerivative,
            smoothingFactor(deltaSeconds, derivativeCutoff),
        )
        val cutoff = minCutoff + beta * kotlin.math.abs(previousDerivative)
        previousValue = lowPass(
            previousValue,
            value,
            smoothingFactor(deltaSeconds, cutoff),
        )
        return previousValue
    }

    private fun smoothingFactor(deltaSeconds: Float, cutoff: Float): Float {
        val tau = 1f / (2f * PI.toFloat() * cutoff.coerceAtLeast(0.001f))
        return 1f / (1f + tau / deltaSeconds)
    }

    private fun lowPass(previous: Float, current: Float, alpha: Float): Float =
        previous + alpha * (current - previous)
}
