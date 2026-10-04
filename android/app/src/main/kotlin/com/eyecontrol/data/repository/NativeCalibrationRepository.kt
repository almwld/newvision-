package com.eyecontrol.data.repository

import com.eyecontrol.data.calibration.CalibrationFeatureSample
import com.eyecontrol.data.calibration.CalibrationAngleSample
import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.calibration.CalibrationSample
import com.eyecontrol.domain.model.CalibrationData
import com.eyecontrol.domain.repository.CalibrationRepository

class NativeCalibrationRepository(
    private val manager: CalibrationManager,
) : CalibrationRepository {
    override suspend fun save(model: CalibrationData) = manager.setModel(model)
    override suspend fun load(): CalibrationData? = manager.loadFromStorage()
    override suspend fun clear() = manager.clear()

    fun hasActiveModel(): Boolean = manager.hasActiveModel()
    fun fitLegacy(samples: List<CalibrationSample>) = manager.fit(samples)
    fun fitV2(samples: List<CalibrationFeatureSample>) = manager.fitV2(samples)
    fun fitAngles(samples: List<CalibrationAngleSample>) = manager.fitAngles(samples)
    fun predict(x: Float, y: Float): Pair<Float, Float> = manager.predict(x, y)
    fun clearNow() = manager.clear()
}
