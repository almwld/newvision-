package com.eyecontrol.data.calibration

import org.junit.Assert.assertTrue
import org.junit.Test

class RidgeCalibrationModelTest {
    @Test
    fun ninePointModel_canFitAndPredict() {
        val samples = listOf(
            CalibrationSample(0f, 0f, 0f, 0f),
            CalibrationSample(0.5f, 0f, 0.5f, 0f),
            CalibrationSample(1f, 0f, 1f, 0f),
            CalibrationSample(0f, 0.5f, 0f, 0.5f),
            CalibrationSample(0.5f, 0.5f, 0.5f, 0.5f),
            CalibrationSample(1f, 0.5f, 1f, 0.5f),
            CalibrationSample(0f, 1f, 0f, 1f),
            CalibrationSample(0.5f, 1f, 0.5f, 1f),
            CalibrationSample(1f, 1f, 1f, 1f),
        )
        val model = RidgeCalibrationModel()
        model.fit(samples)
        val prediction = model.predict(0.5f, 0.5f)
        assertTrue(model.isFitted())
        assertTrue(prediction.first in 0.45f..0.55f)
        assertTrue(prediction.second in 0.45f..0.55f)
    }
}
