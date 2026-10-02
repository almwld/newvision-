package com.eyecontrol.data.decision

import com.eyecontrol.domain.model.ScreenPoint
import org.junit.Assert.assertEquals
import org.junit.Test

class IntentDetectorTest {
    private fun point(x: Float, y: Float, ts: Long, blink: Boolean = false) =
        ScreenPoint(x, y, 1f, blink, ts)

    @Test
    fun firstValidPoint_isFixation() {
        val detector = IntentDetector()
        assertEquals(GazeIntent.FIXATION, detector.detect(point(0f, 0f, 1_000_000_000L)))
    }

    @Test
    fun slowMovement_isFixation() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 1_000_000_000L))
        assertEquals(GazeIntent.FIXATION, detector.detect(point(20f, 0f, 1_500_000_000L)))
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
    fun blink_doesNotReplacePreviousPoint() {
        val detector = IntentDetector()
        detector.detect(point(100f, 100f, 1_000_000_000L))
        assertEquals(GazeIntent.FIXATION, detector.detect(point(100f, 100f, 1_100_000_000L, true)))
        assertEquals(GazeIntent.FIXATION, detector.detect(point(100f, 100f, 1_200_000_000L)))
    }

    @Test
    fun outOfOrderPoint_doesNotPoisonNextComparison() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 2_000_000_000L))
        assertEquals(GazeIntent.FIXATION, detector.detect(point(900f, 900f, 1_000_000_000L)))
        assertEquals(GazeIntent.SACCADE, detector.detect(point(300f, 0f, 2_100_000_000L)))
    }

    @Test
    fun reset_forgetsPreviousPoint() {
        val detector = IntentDetector()
        detector.detect(point(0f, 0f, 1_000_000_000L))
        detector.reset()
        assertEquals(GazeIntent.FIXATION, detector.detect(point(900f, 900f, 2_000_000_000L)))
    }

    @Test
    fun invalidThresholds_areRejected() {
        kotlin.runCatching { IntentDetector(-1f, 1200f) }.let { assertEquals(true, it.isFailure) }
        kotlin.runCatching { IntentDetector(80f, 80f) }.let { assertEquals(true, it.isFailure) }
    }
}
