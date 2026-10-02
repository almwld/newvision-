package com.eyecontrol.pipeline

import com.eyecontrol.data.calibration.CalibrationFeatureSample
import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.filter.GazeSmoother
import com.eyecontrol.domain.model.GazeSample
import com.eyecontrol.domain.usecase.ProcessGazeUseCase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.abs

class GazePipelineIntegrationTest {
    private fun sample(
        x: Float,
        y: Float,
        open: Boolean = true,
        ts: Long = 1_000_000_000L,
    ) = GazeSample(x, y, x, y, x, y, 0.9f, 0.1f, open, ts)

    @Test
    fun centerInput_producesNearCenterAfterCalibration() {
        val manager = CalibrationManager(null)
        val samples = buildList {
            repeat(100) {
                for (row in 0..2) for (column in 0..2) {
                    val x = floatArrayOf(0.1f, 0.5f, 0.9f)[column]
                    val y = floatArrayOf(0.1f, 0.5f, 0.9f)[row]
                    add(CalibrationFeatureSample(x, y, x, y, x, y))
                }
            }
        }
        manager.fitV2(samples)
        val processor = ProcessGazeUseCase(GazeSmoother(), manager, 1000, 1000)
        val point = processor.process(sample(0.5f, 0.5f))
        assertNotNull(point)
        assertEquals(500f, point!!.xPx, 20f)
        assertEquals(500f, point.yPx, 20f)
    }

    @Test
    fun blink_returnsLastValidPoint() {
        val processor = ProcessGazeUseCase(GazeSmoother(), CalibrationManager(null), 1000, 1000)
        processor.process(sample(0.5f, 0.5f))
        val point = processor.process(sample(0.5f, 0.5f, open = false, ts = 2_000_000_000L))
        assertNotNull(point)
        assertTrue(point!!.isBlinking)
    }

    @Test
    fun firstBlink_returnsNull() {
        val processor = ProcessGazeUseCase(GazeSmoother(), CalibrationManager(null), 1000, 1000)
        assertEquals(null, processor.process(sample(0.5f, 0.5f, open = false)))
    }

    @Test
    fun noisyInput_hasLowerFilteredVariance() {
        val filter = GazeSmoother()
        val raw = (0 until 40).map { 0.5f + if (it % 2 == 0) 0.08f else -0.08f }
        val filtered = raw.mapIndexed { index, value ->
            filter.filter(value, 0.5f, index * 33L, 0.9f).first
        }
        fun variance(values: List<Float>): Float {
            val mean = values.average().toFloat()
            return values.sumOf { ((it - mean) * (it - mean)).toDouble() }.toFloat() / values.size
        }
        assertTrue(variance(filtered) < variance(raw))
    }

    @Test
    fun rapidMovement_producesFiniteOutput() {
        val processor = ProcessGazeUseCase(GazeSmoother(), CalibrationManager(null), 1000, 1000)
        var point = processor.process(sample(0.1f, 0.5f))!!
        for (i in 1..10) {
            point = processor.process(sample(0.9f, 0.5f, ts = 1_000_000_000L + i * 16_000_000L))!!
        }
        assertTrue(point.xPx.isFinite())
        assertTrue(point.yPx.isFinite())
    }

    @Test
    fun noCalibration_fallsBackToAverageEyeFeatures() {
        val processor = ProcessGazeUseCase(GazeSmoother(), CalibrationManager(null), 1000, 1000)
        val point = processor.process(
            GazeSample(0.5f, 0.5f, 0.2f, 0.3f, 0.4f, 0.5f, 0.9f, 0.1f, true, 1_000_000_000L),
        )
        assertNotNull(point)
        assertTrue(abs(point!!.xPx - 300f) < 30f)
        assertTrue(abs(point.yPx - 400f) < 30f)
    }

    @Test
    fun outOfOrderTimestamp_doesNotCrash() {
        val processor = ProcessGazeUseCase(GazeSmoother(), CalibrationManager(null), 1000, 1000)
        processor.process(sample(0.4f, 0.4f, ts = 2_000_000_000L))
        val point = processor.process(sample(0.6f, 0.6f, ts = 1_000_000_000L))
        assertNotNull(point)
    }
}
