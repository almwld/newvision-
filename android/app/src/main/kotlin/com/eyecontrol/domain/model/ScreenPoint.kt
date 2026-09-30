package com.eyecontrol.domain.model

data class ScreenPoint(
    val xPx: Float,
    val yPx: Float,
    val confidence: Float,
    val isBlinking: Boolean,
    val timestampNs: Long,
)
