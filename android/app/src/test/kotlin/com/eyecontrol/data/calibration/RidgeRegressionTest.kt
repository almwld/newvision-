package com.eyecontrol.data.calibration

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RidgeRegressionTest {
    private val x = Array(9) { row ->
        val y = row / 8f
        floatArrayOf(y, y, 1f - y, 1f - y)
    }
    private val targets = Array(9) { row ->
        val y = row / 8f
        floatArrayOf(y, y)
    }

    @Test
    fun producesFiveByTwoWeightMatrix() {
        val weights = RidgeRegression().fit(x, targets)
        assertEquals(5, weights.size)
        assertEquals(2, weights.first().size)
    }

    @Test
    fun predictionWeightsAreFinite() {
        val weights = RidgeRegression().fit(x, targets)
        assertTrue(weights.all { row -> row.all(Float::isFinite) })
    }

    @Test
    fun acceptsMoreThanNineSamples() {
        val weights = RidgeRegression().fit(Array(18) { x[it % 9] }, Array(18) { targets[it % 9] })
        assertEquals(5, weights.size)
    }

    @Test
    fun rejectsWrongFeatureCount() {
        assertTrue(runCatching {
            RidgeRegression().fit(Array(1) { floatArrayOf(1f, 2f, 3f) }, Array(1) { floatArrayOf(1f, 1f) })
        }.isFailure)
    }

    @Test
    fun rejectsMismatchedTargetRows() {
        assertTrue(runCatching {
            RidgeRegression().fit(
                Array(2) { floatArrayOf(0f, 0f, 0f, 0f) },
                Array(1) { floatArrayOf(0f, 0f) },
            )
        }.isFailure)
    }

    @Test
    fun rejectsEmptyDataset() {
        assertTrue(runCatching {
            RidgeRegression().fit(emptyArray(), emptyArray())
        }.isFailure)
    }

    @Test
    fun regularizationKeepsDegenerateSamplesFinite() {
        val weights = RidgeRegression(lambda = 1e-2f).fit(
            Array(9) { floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f) },
            Array(9) { floatArrayOf(0.25f, 0.75f) },
        )
        assertTrue(weights.all { row -> row.all(Float::isFinite) })
    }

    @Test
    fun rejectsNonFiniteInput() {
        assertTrue(runCatching {
            RidgeRegression().fit(Array(1) { floatArrayOf(Float.NaN, 0f, 0f, 0f) }, Array(1) { floatArrayOf(1f, 1f) })
        }.isFailure)
    }
}
