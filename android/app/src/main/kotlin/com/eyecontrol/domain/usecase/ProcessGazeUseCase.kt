package com.eyecontrol.domain.usecase

import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.filter.GazeSmoother
import com.eyecontrol.domain.model.GazeSample
import com.eyecontrol.domain.model.ScreenPoint

class ProcessGazeUseCase(
    private val smoother: GazeSmoother,
    private val calibrationManager: CalibrationManager,
    private val screenWidth: Int,
    private val screenHeight: Int,
) {
    private var lastValidPoint: ScreenPoint? = null

    fun process(sample: GazeSample): ScreenPoint? {
        if (!sample.eyeOpen) {
            return lastValidPoint?.copy(
                confidence = sample.confidence,
                isBlinking = true,
                timestampNs = sample.timestampNs,
            )
        }

        val (smoothX, smoothY) = smoother.filter(
            sample.rawX,
            sample.rawY,
            sample.timestampNs / 1_000_000L,
            sample.confidence,
        )
        val normalized = calibrationManager.transform(floatArrayOf(smoothX, smoothY))
        val point = ScreenPoint(
            xPx = (normalized.first.coerceIn(0f, 1f) * screenWidth)
                .coerceIn(0f, (screenWidth - 1).coerceAtLeast(0).toFloat()),
            yPx = (normalized.second.coerceIn(0f, 1f) * screenHeight)
                .coerceIn(0f, (screenHeight - 1).coerceAtLeast(0).toFloat()),
            confidence = sample.confidence,
            isBlinking = false,
            timestampNs = sample.timestampNs,
        )
        lastValidPoint = point
        return point
    }

    fun reset() {
        smoother.reset()
        lastValidPoint = null
    }
}
