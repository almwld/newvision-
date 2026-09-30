package com.eyecontrol.data.repository

import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.filter.GazeSmoother
import com.eyecontrol.domain.model.GazeSample
import com.eyecontrol.domain.model.ScreenPoint
import com.eyecontrol.domain.repository.GazeRepository
import com.eyecontrol.domain.usecase.ProcessGazeUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class NativeGazeRepository(
    calibrationManager: CalibrationManager,
    screenWidth: Int,
    screenHeight: Int,
) : GazeRepository {
    private val processor = ProcessGazeUseCase(
        smoother = GazeSmoother(),
        calibrationManager = calibrationManager,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
    )
    private val _latest = MutableStateFlow<GazeSample?>(null)
    private val _latestScreenPoint = MutableStateFlow<ScreenPoint?>(null)

    override val latest: StateFlow<GazeSample?> = _latest.asStateFlow()

    override fun publish(sample: GazeSample) {
        _latest.value = sample
        _latestScreenPoint.value = processor.process(sample)
    }

    override fun latestScreenPoint(): StateFlow<ScreenPoint?> = _latestScreenPoint.asStateFlow()

    override fun reset() {
        processor.reset()
        _latest.value = null
        _latestScreenPoint.value = null
    }

    override fun clear() = reset()
}
