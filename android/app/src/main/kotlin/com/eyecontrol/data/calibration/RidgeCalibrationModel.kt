package com.eyecontrol.data.calibration

import kotlin.math.abs

data class CalibrationSample(
    val x: Float,
    val y: Float,
    val targetX: Float,
    val targetY: Float,
)

class RidgeCalibrationModel(
    private val lambda: Double = 0.01,
) {
    private var coefficientsX: DoubleArray? = null
    private var coefficientsY: DoubleArray? = null

    fun fit(samples: List<CalibrationSample>) {
        require(samples.size >= 9) { "Nine calibration samples are required." }
        val design = samples.map(::features)
        coefficientsX = solve(design, samples.map { it.targetX.toDouble() })
        coefficientsY = solve(design, samples.map { it.targetY.toDouble() })
    }

    fun isFitted(): Boolean = coefficientsX != null && coefficientsY != null

    fun predict(x: Float, y: Float): Pair<Float, Float> {
        val cx = coefficientsX ?: error("Calibration model is not fitted.")
        val cy = coefficientsY ?: error("Calibration model is not fitted.")
        val vector = features(CalibrationSample(x, y, 0f, 0f))
        return Pair(
            dot(cx, vector).toFloat().coerceIn(0f, 1f),
            dot(cy, vector).toFloat().coerceIn(0f, 1f),
        )
    }

    fun serialize(): String? {
        val cx = coefficientsX ?: return null
        val cy = coefficientsY ?: return null
        return cx.joinToString(",") + "|" + cy.joinToString(",")
    }

    fun restore(serialized: String): Boolean {
        val sections = serialized.split('|')
        if (sections.size != 2) return false
        val x = parseCoefficients(sections[0]) ?: return false
        val y = parseCoefficients(sections[1]) ?: return false
        coefficientsX = x
        coefficientsY = y
        return true
    }

    fun clear() {
        coefficientsX = null
        coefficientsY = null
    }

    private fun parseCoefficients(value: String): DoubleArray? {
        val parts = value.split(',')
        if (parts.size != 6) return null
        return runCatching {
            DoubleArray(6) { parts[it].toDouble() }
        }.getOrNull()
    }

    private fun features(sample: CalibrationSample): DoubleArray {
        val x = sample.x.toDouble()
        val y = sample.y.toDouble()
        return doubleArrayOf(1.0, x, y, x * x, x * y, y * y)
    }

    private fun solve(
        design: List<DoubleArray>,
        targets: List<Double>,
    ): DoubleArray {
        val dimension = design.first().size
        val normal = Array(dimension) { DoubleArray(dimension + 1) }
        design.forEachIndexed { row, feature ->
            for (i in 0 until dimension) {
                for (j in 0 until dimension) normal[i][j] += feature[i] * feature[j]
                normal[i][dimension] += feature[i] * targets[row]
            }
        }
        for (i in 0 until dimension) normal[i][i] += lambda
        for (pivot in 0 until dimension) {
            var best = pivot
            for (row in pivot + 1 until dimension) {
                if (abs(normal[row][pivot]) > abs(normal[best][pivot])) best = row
            }
            if (abs(normal[best][pivot]) < 1e-12) error("Singular calibration matrix.")
            val tmp = normal[pivot]
            normal[pivot] = normal[best]
            normal[best] = tmp
            val divisor = normal[pivot][pivot]
            for (column in pivot until dimension + 1) normal[pivot][column] /= divisor
            for (row in 0 until dimension) {
                if (row == pivot) continue
                val factor = normal[row][pivot]
                for (column in pivot until dimension + 1) {
                    normal[row][column] -= factor * normal[pivot][column]
                }
            }
        }
        return DoubleArray(dimension) { normal[it][dimension] }
    }

    private fun dot(a: DoubleArray, b: DoubleArray): Double =
        a.indices.sumOf { a[it] * b[it] }
}
