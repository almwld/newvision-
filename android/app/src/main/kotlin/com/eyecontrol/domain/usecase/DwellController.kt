package com.eyecontrol.domain.usecase

import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.data.decision.IntentDetector
import com.eyecontrol.domain.model.DwellState
import com.eyecontrol.domain.model.ScreenPoint

class DwellController(
    durationMs: Long = NativeConstants.DWELL_DURATION_MS,
    radiusPx: Float = NativeConstants.DWELL_RADIUS_PX,
    onDwell: (Float, Float) -> Unit,
) {
    private val useCase = DetectDwellUseCase(
        onDwell = onDwell,
        intentDetector = IntentDetector(),
    )

    init {
        useCase.configure(durationMs, radiusPx)
    }

    fun update(point: ScreenPoint): DwellState = useCase.update(point)

    fun configure(durationMs: Long, radiusPx: Float) {
        useCase.configure(durationMs, radiusPx)
    }

    fun reset() {
        useCase.reset()
    }
}
