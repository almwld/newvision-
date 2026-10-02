package com.eyecontrol.data.calibration

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CholeskySolverTest {
    @Test
    fun solvesSingleValue() {
        val result = CholeskySolver().solve(
            arrayOf(floatArrayOf(4f)),
            arrayOf(floatArrayOf(8f)),
        )
        assertEquals(2f, result[0][0], 0.0001f)
    }

    @Test
    fun solvesSymmetricPositiveDefiniteMatrix() {
        val result = CholeskySolver().solve(
            arrayOf(floatArrayOf(4f, 2f), floatArrayOf(2f, 3f)),
            arrayOf(floatArrayOf(6f), floatArrayOf(7f)),
        )
        assertEquals(0.5f, result[0][0], 0.0001f)
        assertEquals(2f, result[1][0], 0.0001f)
    }

    @Test
    fun supportsMultipleRightHandSides() {
        val result = CholeskySolver().solve(
            arrayOf(floatArrayOf(4f, 2f), floatArrayOf(2f, 3f)),
            arrayOf(floatArrayOf(6f, 8f), floatArrayOf(7f, 10f)),
        )
        assertEquals(0.5f, result[0][0], 0.0001f)
        assertEquals(2f, result[1][0], 0.0001f)
        assertEquals(0.5f, result[0][1], 0.0001f)
        assertEquals(3f, result[1][1], 0.0001f)
    }

    @Test
    fun rejectsNonPositiveDefiniteMatrix() {
        val failed = runCatching {
            CholeskySolver().solve(
                arrayOf(floatArrayOf(0f)),
                arrayOf(floatArrayOf(1f)),
            )
        }.isFailure
        assertTrue(failed)
    }
}
