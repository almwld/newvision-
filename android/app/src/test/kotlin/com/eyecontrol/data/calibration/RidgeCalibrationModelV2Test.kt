package com.eyecontrol.data.calibration

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RidgeCalibrationModelV2Test {
    private fun model(): RidgeCalibrationModelV2 {
        val model = RidgeCalibrationModelV2()
        val x = Array(9) { row ->
            val v = row / 8f
            floatArrayOf(v, v, v, v)
        }
        val y = Array(9) { row ->
            val v = row / 8f
            floatArrayOf(v, v)
        }
        model.fit(x, y)
        return model
    }

    @Test
    fun predictsBoundedCoordinates() {
        val point = model().predict(floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f))
        assertTrue(point.first in 0f..1f)
        assertTrue(point.second in 0f..1f)
    }

    @Test
    fun serializesToTenValues() {
        assertEquals(10, model().toFlatArray().size)
    }

    @Test
    fun flatRoundTripPreservesPrediction() {
        val source = model()
        val restored = RidgeCalibrationModelV2.fromFlatArray(source.toFlatArray())
        assertTrue(restored != null)
        val a = source.predict(floatArrayOf(0.35f, 0.35f, 0.35f, 0.35f))
        val b = restored!!.predict(floatArrayOf(0.35f, 0.35f, 0.35f, 0.35f))
        assertEquals(a.first, b.first, 0.0001f)
        assertEquals(a.second, b.second, 0.0001f)
    }
}
