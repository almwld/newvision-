package com.eyecontrol.data.settings

import com.eyecontrol.domain.model.ScreenPoint

enum class GazeZone {
    TOP, BOTTOM, LEFT, RIGHT
}

class GazeZoneDetector(
    private val screenWidth: Int,
    private val screenHeight: Int,
    private val settingsProvider: () -> GazeZoneSettings,
) {
    fun detect(point: ScreenPoint): GazeZone? {
        val settings = settingsProvider()
        if (!settings.enabled || point.isBlinking || screenWidth <= 0 || screenHeight <= 0) return null

        val nx = (point.xPx / screenWidth.toFloat()).coerceIn(0f, 1f)
        val ny = (point.yPx / screenHeight.toFloat()).coerceIn(0f, 1f)
        val threshold = settings.edgeThreshold

        return when {
            ny < threshold && settings.scrollUpEnabled -> GazeZone.TOP
            ny > 1f - threshold && settings.scrollDownEnabled -> GazeZone.BOTTOM
            nx < threshold && settings.scrollLeftEnabled -> GazeZone.LEFT
            nx > 1f - threshold && settings.scrollRightEnabled -> GazeZone.RIGHT
            else -> null
        }
    }
}
