package com.eyecontrol.data.vision

import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import kotlin.math.hypot

/**
 * Stateful hysteresis blink detector based on eye aspect ratio.
 */
class BlinkDetector(
    private val closedThreshold: Float = 0.20f,
    private val openThreshold: Float = 0.28f,
) {
    private var blinking = false

    fun update(leftEye: List<NormalizedLandmark>, rightEye: List<NormalizedLandmark>): Boolean {
        val left = eyeAspectRatio(leftEye) ?: return blinking
        val right = eyeAspectRatio(rightEye) ?: return blinking
        val closed = (left + right) * 0.5f < closedThreshold
        val open = (left + right) * 0.5f > openThreshold
        if (!blinking && closed) blinking = true
        if (blinking && open) blinking = false
        return blinking
    }

    fun reset() {
        blinking = false
    }

    private fun eyeAspectRatio(eye: List<NormalizedLandmark>): Float? {
        if (eye.size < 6) return null
        val verticalA = distance(eye[1], eye[5])
        val verticalB = distance(eye[2], eye[4])
        val horizontal = distance(eye[0], eye[3])
        if (horizontal < 1e-5f) return null
        return (verticalA + verticalB) / (2f * horizontal)
    }

    private fun distance(a: NormalizedLandmark, b: NormalizedLandmark): Float =
        hypot((a.x() - b.x()).toDouble(), (a.y() - b.y()).toDouble()).toFloat()
}
