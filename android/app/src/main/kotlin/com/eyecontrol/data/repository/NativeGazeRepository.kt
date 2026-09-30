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

/**
 * Single in-process source of truth for raw gaze samples and their screen projection.
 *
 * Samples are accepted in timestamp order only. A late native/camera frame must not
 * move the cursor backwards or overwrite a newer point already consumed by the UI.
 */
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
    private var latestTimestampNs = Long.MIN_VALUE

    override val latest: StateFlow<GazeSample?> = _latest.asStateFlow()

    override fun publish(sample: GazeSample) {
        if (sample.timestampNs <= latestTimestampNs) return
        latestTimestampNs = sample.timestampNs
        _latest.value = sample
        _latestScreenPoint.value = processor.process(sample)
    }

    override fun latestScreenPoint(): StateFlow<ScreenPoint?> = _latestScreenPoint.asStateFlow()

    override fun reset() {
        processor.reset()
        _latest.value = null
        _latestScreenPoint.value = null
        latestTimestampNs = Long.MIN_VALUE
    }

    override fun clear() = reset()
}
