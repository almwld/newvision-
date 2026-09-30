package com.eyecontrol.domain.model

data class GazeFrame(
    val x: Float,
    val y: Float,
    val confidence: Float,
    val timestampMs: Long,
    val blinking: Boolean,
)
