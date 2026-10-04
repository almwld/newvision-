package com.eyecontrol.data.calibration

import com.eyecontrol.domain.model.CalibrationData

class CalibrationManager(
    private val store: CalibrationStore?,
    private val legacyModel: RidgeCalibrationModel = RidgeCalibrationModel(),
    private val modelV2: RidgeCalibrationModelV2 = RidgeCalibrationModelV2(),
    private val angleModel: RidgeCalibrationModelV2 = RidgeCalibrationModelV2(),
) {
    private var activeVersion = 0

    init { loadFromStorage() }

    fun loadFromStorage(): CalibrationData? {
        val serialized = store?.read() ?: return null
        if (serialized.startsWith(V3_PREFIX)) {
            val flat = serialized.removePrefix(V3_PREFIX).split(',').mapNotNull { it.toFloatOrNull() }
            if (!angleModel.restore(flat.toFloatArray())) {
                angleModel.clear()
                activeVersion = 0
                return null
            }
            activeVersion = 3
            return CalibrationData(version = 3, payload = serialized)
        }

        if (serialized.startsWith(V2_PREFIX)) {
            val flat = serialized.removePrefix(V2_PREFIX).split(',').mapNotNull { it.toFloatOrNull() }
            if (!modelV2.restore(flat.toFloatArray())) {
                modelV2.clear()
                activeVersion = 0
                return null
            }
            activeVersion = 2
            return CalibrationData(version = 2, payload = serialized)
        }

        if (!legacyModel.restore(serialized)) {
            legacyModel.clear()
            activeVersion = 0
            return null
        }
        activeVersion = 1
        return CalibrationData(version = 1, payload = serialized)
    }

    fun hasActiveModel(): Boolean = activeVersion != 0

    fun activeVersion(): Int = activeVersion

    fun transform(features: FloatArray): Pair<Float, Float> {
        require(features.size == 4) { "Exactly four eye features are required." }
        return when (activeVersion) {
            3 -> angleModel.predict(features)
            2 -> modelV2.predict(features)
            1 -> legacyModel.predict(
                (features[0] + features[2]) * 0.5f,
                (features[1] + features[3]) * 0.5f,
            )
            else -> Pair(
                ((features[0] + features[2]) * 0.5f).coerceIn(0f, 1f),
                ((features[1] + features[3]) * 0.5f).coerceIn(0f, 1f),
            )
        }
    }

    fun setModel(data: CalibrationData) {
        when (data.version) {
            1 -> {
                require(legacyModel.restore(data.payload))
                activeVersion = 1
                store?.write(data.payload)
            }
            3 -> {
                val encoded = data.payload.removePrefix(V3_PREFIX)
                val flat = encoded.split(',').mapNotNull { it.toFloatOrNull() }.toFloatArray()
                require(angleModel.restore(flat))
                activeVersion = 3
                store?.write(V3_PREFIX + flat.joinToString(","))
            }
            2 -> {
                val encoded = data.payload.removePrefix(V2_PREFIX)
                val flat = encoded.split(',').mapNotNull { it.toFloatOrNull() }.toFloatArray()
                require(modelV2.restore(flat))
                activeVersion = 2
                store?.write(V2_PREFIX + flat.joinToString(","))
            }
            else -> error("Unsupported calibration version ${data.version}.")
        }
    }

    fun fit(samples: List<CalibrationSample>) {
        legacyModel.fit(samples)
        activeVersion = 1
        legacyModel.serialize()?.let { store?.write(it) }
    }

    fun fitV2(samples: List<CalibrationFeatureSample>) {
        require(samples.size >= 9) { "Nine calibration samples are required." }
        val x = Array(samples.size) { samples[it].features() }
        val y = Array(samples.size) {
            floatArrayOf(samples[it].targetX, samples[it].targetY)
        }
        modelV2.fit(x, y)
        activeVersion = 2
        store?.write(V2_PREFIX + modelV2.toFlatArray().joinToString(","))
    }

    fun fitAngles(samples: List<CalibrationAngleSample>) {
        require(samples.size >= 9) { "Nine calibration samples are required." }
        val x = Array(samples.size) { floatArrayOf(samples[it].yawDegrees, samples[it].pitchDegrees, 0f, 0f) }
        val y = Array(samples.size) { floatArrayOf(samples[it].targetX, samples[it].targetY) }
        angleModel.fit(x, y)
        activeVersion = 3
        store?.write(V3_PREFIX + angleModel.toFlatArray().joinToString(","))
    }

    fun transformAngles(yaw: Float, pitch: Float): Pair<Float, Float> =
        angleModel.predict(floatArrayOf(yaw, pitch, 0f, 0f))

    fun predict(x: Float, y: Float): Pair<Float, Float> =
        transform(floatArrayOf(x, y, x, y))

    fun clear() {
        legacyModel.clear()
        modelV2.clear()
        activeVersion = 0
        store?.clear()
    }

    companion object {
        const val V2_PREFIX = "v2|"
        const val V3_PREFIX = "v3|"
    }
}
