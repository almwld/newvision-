package com.eyecontrol.data.calibration

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RidgeCalibrationModelTest {
    @Test
    fun fitsNinePointQuadraticModel() {
        val model = RidgeCalibrationModel()
        val samples = listOf(
            CalibrationSample(0.1f, 0.1f, 0.1f, 0.1f),
            CalibrationSample(0.5f, 0.1f, 0.5f, 0.1f),
            CalibrationSample(0.9f, 0.1f, 0.9f, 0.1f),
            CalibrationSample(0.1f, 0.5f, 0.1f, 0.5f),
            CalibrationSample(0.5f, 0.5f, 0.5f, 0.5f),
            CalibrationSample(0.9f, 0.5f, 0.9f, 0.5f),
            CalibrationSample(0.1f, 0.9f, 0.1f, 0.9f),
            CalibrationSample(0.5f, 0.9f, 0.5f, 0.9f),
            CalibrationSample(0.9f, 0.9f, 0.9f, 0.9f),
        )
        model.fit(samples)
        assertTrue(model.isFitted())
        val prediction = model.predict(0.5f, 0.5f)
        assertEquals(0.5f, prediction.first, 0.05f)
        assertEquals(0.5f, prediction.second, 0.05f)
    }

    @Test
    fun serializedModelCanBeRestored() {
        val source = RidgeCalibrationModel()
        source.fit(
            listOf(
                CalibrationSample(0.1f, 0.1f, 0.1f, 0.1f),
                CalibrationSample(0.5f, 0.1f, 0.5f, 0.1f),
                CalibrationSample(0.9f, 0.1f, 0.9f, 0.1f),
                CalibrationSample(0.1f, 0.5f, 0.1f, 0.5f),
                CalibrationSample(0.5f, 0.5f, 0.5f, 0.5f),
                CalibrationSample(0.9f, 0.5f, 0.9f, 0.5f),
                CalibrationSample(0.1f, 0.9f, 0.1f, 0.9f),
                CalibrationSample(0.5f, 0.9f, 0.5f, 0.9f),
                CalibrationSample(0.9f, 0.9f, 0.9f, 0.9f),
            ),
        )
        val serialized = source.serialize()
        requireNotNull(serialized)
        val restored = RidgeCalibrationModel()
        assertTrue(restored.restore(serialized))
        val prediction = restored.predict(0.5f, 0.5f)
        assertEquals(0.5f, prediction.first, 0.05f)
        assertEquals(0.5f, prediction.second, 0.05f)
    }
}
