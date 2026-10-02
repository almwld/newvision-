package com.eyecontrol.data.calibration

class RidgeRegression(
    private val lambda: Float = 1.0f,
) {
    fun fit(x: Array<FloatArray>, y: Array<FloatArray>): Array<FloatArray> {
        require(x.isNotEmpty()) { "Training matrix X must not be empty." }
        require(x.size == y.size) { "X and Y row counts must match." }
        require(x.first().size == 4) { "Ridge calibration requires four eye features." }
        require(y.first().size == 2) { "Ridge calibration requires X/Y targets." }
        require(x.all { it.size == 4 && it.all(Float::isFinite) })
        require(y.all { it.size == 2 && it.all(Float::isFinite) })
        require(lambda > 0f && lambda.isFinite())

        val n = x.size
        val features = 5
        val design = Array(n) { row ->
            floatArrayOf(1f, x[row][0], x[row][1], x[row][2], x[row][3])
        }
        val xt = transpose(design)
        val xtx = matmul(xt, design)
        for (i in 0 until features) xtx[i][i] += lambda
        return CholeskySolver().solve(xtx, matmul(xt, y))
    }

    private fun transpose(a: Array<FloatArray>): Array<FloatArray> =
        Array(a.first().size) { column ->
            FloatArray(a.size) { row -> a[row][column] }
        }

    private fun matmul(a: Array<FloatArray>, b: Array<FloatArray>): Array<FloatArray> {
        require(a.first().size == b.size)
        return Array(a.size) { i ->
            FloatArray(b.first().size) { j ->
                var sum = 0f
                for (k in b.indices) sum += a[i][k] * b[k][j]
                sum
            }
        }
    }
}
