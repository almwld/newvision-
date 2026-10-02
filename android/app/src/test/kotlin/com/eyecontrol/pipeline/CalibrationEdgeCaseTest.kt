package com.eyecontrol.pipeline

import com.eyecontrol.data.calibration.CalibrationFeatureSample
import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.calibration.RidgeCalibrationModelV2
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CalibrationEdgeCaseTest {
    private fun sample(offset: Float = 0f) = CalibrationFeatureSample(
        0.5f + offset, 0.5f, 0.5f - offset, 0.5f,
        0.5f, 0.5f,
    )

    @Test
    fun tooFewPoints_fails() {
        val manager = CalibrationManager(null)
        assertTrue(runCatching { manager.fitV2(List(8) { sample() }) }.isFailure)
    }

    @Test
    fun duplicatePoints_areHandled() {
        val manager = CalibrationManager(null)
        manager.fitV2(List(9) { sample() })
        assertTrue(manager.hasActiveModel())
    }

    @Test
    fun outlierDoesNotCrashModel() {
        val manager = CalibrationManager(null)
        val points = List(9) { sample() }.toMutableList()
        points[8] = sample(0.4f)
        manager.fitV2(points)
        assertTrue(manager.hasActiveModel())
    }

    @Test
    fun invalidCoordinates_areRejected() {
        val model = RidgeCalibrationModelV2()
        assertFalse(model.restore(FloatArray(10) { if (it == 3) Float.NaN else 0f }))
    }

    @Test
    fun flatWeights_surviveRoundTrip() {
        val model = RidgeCalibrationModelV2()
        model.fit(
            Array(90) {
                val v = (it % 9) / 8f
                floatArrayOf(v, v, v, v)
            },
            Array(90) {
                val v = (it % 9) / 8f
                floatArrayOf(v, v)
            },
        )
        val restored = RidgeCalibrationModelV2.fromFlatArray(model.toFlatArray())
        assertTrue(restored != null)
        assertEquals(
            model.predict(floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f)).first,
            restored!!.predict(floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f)).first,
            0.0001f,
        )
    }

    @Test
    fun corruptedWeights_reloadGracefully() {
        assertFalse(RidgeCalibrationModelV2.fromFlatArray(floatArrayOf(1f, 2f)) != null)
    }

    @Test
    fun recalibration_replacesOldModel() {
        val manager = CalibrationManager(null)
        manager.fitV2(List(90) { sample() })
        val first = manager.predict(0.5f, 0.5f)
        manager.fitV2(List(90) { sample(0.2f) })
        val second = manager.predict(0.5f, 0.5f)
        assertTrue(first != second)
    }

    @Test
    fun reset_clearsModel() {
        val manager = CalibrationManager(null)
        manager.fitV2(List(9) { sample() })
        manager.clear()
        assertFalse(manager.hasActiveModel())
    }
}
