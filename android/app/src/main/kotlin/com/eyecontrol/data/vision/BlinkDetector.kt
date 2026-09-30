package com.eyecontrol.data.vision

import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import kotlin.math.hypot

class BlinkDetector(
    private val closedThreshold: Float = 0.22f,
    private val openThreshold: Float = 0.28f,
) {
    private var blinking = false

    fun update(eye: List<NormalizedLandmark>): Boolean {
        if (eye.size < 6) return blinking
        val vertical = hypot(
            (eye[1].x() - eye[5].x()).toDouble(),
            (eye[1].y() - eye[5].y()).toDouble(),
        ).toFloat() + hypot(
            (eye[2].x() - eye[4].x()).toDouble(),
            (eye[2].y() - eye[4].y()).toDouble(),
        ).toFloat()
        val horizontal = hypot(
            (eye[0].x() - eye[3].x()).toDouble(),
            (eye[0].y() - eye[3].y()).toDouble(),
        ).toFloat()
        if (horizontal < 1e-4f) return blinking
        val ratio = vertical / (2f * horizontal)
        if (!blinking && ratio < closedThreshold) blinking = true
        if (blinking && ratio > openThreshold) blinking = false
        return blinking
    }
}
