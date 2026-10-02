package com.eyecontrol.data.vision

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class GazeEstimatorTest {
    @Test
    fun centerBinDecodesToZeroDegrees() {
        val probs = FloatArray(90)
        probs[45] = 1f
        assertEquals(0f, GazeEstimator.decodeAngle(probs), 0.0001f)
    }

    @Test
    fun firstBinDecodesToMinus180Degrees() {
        val probs = FloatArray(90)
        probs[0] = 1f
        assertEquals(-180f, GazeEstimator.decodeAngle(probs), 0.0001f)
    }

    @Test
    fun lastBinDecodesToPlus176Degrees() {
        val probs = FloatArray(90)
        probs[89] = 1f
        assertEquals(176f, GazeEstimator.decodeAngle(probs), 0.0001f)
    }

    @Test
    fun invalidOutputShapeReturnsSafeZero() {
        assertTrue(GazeEstimator.decodeAngle(FloatArray(3)) == 0f)
    }
}
