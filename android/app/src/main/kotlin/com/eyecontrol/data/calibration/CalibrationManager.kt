package com.eyecontrol.data.calibration

import com.eyecontrol.domain.model.CalibrationData

class CalibrationManager(
    private val store: CalibrationStore?,
    private val legacyModel: RidgeCalibrationModel = RidgeCalibrationModel(),
) {
    init { loadFromStorage() }

    fun loadFromStorage(): CalibrationData? {
        val serialized = store?.read() ?: return null
        if (!legacyModel.restore(serialized)) {
            legacyModel.clear()
            return null
        }
        return CalibrationData(version = 1, payload = serialized)
    }

    fun hasActiveModel(): Boolean = legacyModel.isFitted()

    fun transform(features: FloatArray): Pair<Float, Float> {
        require(features.size >= 2) { "At least two gaze features are required." }
        if (!legacyModel.isFitted()) return Pair(features[0], features[1])
        return legacyModel.predict(features[0], features[1])
    }

    fun setModel(data: CalibrationData) {
        require(data.version == 1) { "Calibration version ${data.version} is not supported yet." }
        require(legacyModel.restore(data.payload)) { "Invalid calibration payload." }
        store?.write(data.payload)
    }

    fun fit(samples: List<CalibrationSample>) {
        legacyModel.fit(samples)
        legacyModel.serialize()?.let { store?.write(it) }
    }

    fun predict(x: Float, y: Float): Pair<Float, Float> = transform(floatArrayOf(x, y))

    fun clear() {
        legacyModel.clear()
        store?.clear()
    }
}
