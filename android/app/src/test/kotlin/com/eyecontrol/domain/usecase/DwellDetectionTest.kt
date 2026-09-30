package com.eyecontrol.domain.usecase

import com.eyecontrol.data.decision.GazeIntent
import com.eyecontrol.data.decision.IntentDetector
import com.eyecontrol.domain.model.ScreenPoint
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class DwellDetectionTest {
    private fun point(x: Float, y: Float, ts: Long, blink: Boolean = false) =
        ScreenPoint(x, y, 1f, blink, ts)

    @Test
    fun firstSample_isFixation() {
        val detector = IntentDetector()
        assertEquals(GazeIntent.FIXATION, detector.detect(point(0f, 0f, 1_000_000_000L)))
    }

    @Test
    fun slowMovement_isFixation() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 1_000_000_000L))
        assertEquals(GazeIntent.FIXATION, detector.detect(point(10f, 0f, 1_500_000_000L)))
    }

    @Test
    fun mediumMovement_isSmoothPursuit() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 1_000_000_000L))
        assertEquals(GazeIntent.SMOOTH_PURSUIT, detector.detect(point(100f, 0f, 1_100_000_000L)))
    }

    @Test
    fun rapidMovement_isSaccade() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 1_000_000_000L))
        assertEquals(GazeIntent.SACCADE, detector.detect(point(300f, 0f, 1_100_000_000L)))
    }

    @Test
    fun saccade_cancelsDwell() {
        var fired = 0
        val useCase = DetectDwellUseCase(
            onDwell = { _, _ -> fired++ },
            intentDetector = IntentDetector(),
        )
        useCase.configure(300L, 50f)
        useCase.update(point(100f, 100f, 1_000_000_000L))
        val state = useCase.update(point(500f, 100f, 1_100_000_000L))
        assertTrue(state.cancelled)
        assertEquals(0, fired)
    }

    @Test
    fun blink_pausesWithoutFiring() {
        var fired = 0
        val useCase = DetectDwellUseCase(onDwell = { _, _ -> fired++ })
        useCase.configure(300L, 50f)
        useCase.update(point(100f, 100f, 1_000_000_000L))
        val state = useCase.update(point(100f, 100f, 1_100_000_000L, true))
        assertTrue(!state.fired)
        assertEquals(0, fired)
    }

    @Test
    fun configureRejectsUnsafeBounds() {
        val useCase = DetectDwellUseCase(onDwell = { _, _ -> })
        assertTrue(runCatching { useCase.configure(100L, 50f) }.isFailure)
        assertTrue(runCatching { useCase.configure(500L, 5f) }.isFailure)
    }

    @Test
    fun reset_clearsIntentAndDwellState() {
        val useCase = DetectDwellUseCase(onDwell = { _, _ -> })
        useCase.configure(300L, 50f)
        useCase.update(point(100f, 100f, 1_000_000_000L))
        useCase.reset()
        assertEquals(0f, useCase.update(point(100f, 100f, 2_000_000_000L, true)).progress, 0.001f)
    }
}
