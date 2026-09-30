package com.eyecontrol.data.calibration

class CholeskySolver {
    fun solve(a: Array<FloatArray>, b: Array<FloatArray>): Array<FloatArray> {
        require(a.isNotEmpty()) { "Matrix A must not be empty." }
        val n = a.size
        require(a.all { it.size == n }) { "Matrix A must be square." }
        require(b.size == n) { "Matrix B row count must match A." }
        val columns = b.firstOrNull()?.size ?: 0
        require(columns > 0 && b.all { it.size == columns }) {
            "Matrix B must have at least one consistent column."
        }

        val l = Array(n) { FloatArray(n) }
        for (i in 0 until n) {
            for (j in 0..i) {
                var sum = a[i][j]
                for (k in 0 until j) sum -= l[i][k] * l[j][k]
                if (i == j) {
                    require(sum.isFinite() && sum > 1e-6f) {
                        "Matrix is not symmetric positive definite."
                    }
                    l[i][j] = kotlin.math.sqrt(sum)
                } else {
                    l[i][j] = sum / l[j][j]
                }
            }
        }

        val y = Array(n) { FloatArray(columns) }
        for (i in 0 until n) {
            for (c in 0 until columns) {
                var sum = b[i][c]
                for (k in 0 until i) sum -= l[i][k] * y[k][c]
                y[i][c] = sum / l[i][i]
            }
        }

        val x = Array(n) { FloatArray(columns) }
        for (i in n - 1 downTo 0) {
            for (c in 0 until columns) {
                var sum = y[i][c]
                for (k in i + 1 until n) sum -= l[k][i] * x[k][c]
                x[i][c] = sum / l[i][i]
            }
        }
        return x
    }
}
