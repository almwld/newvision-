package com.eyecontrol.data.calibration

class RidgeCalibrationModelV2(
    private val regression: RidgeRegression = RidgeRegression(),
) {
    private var weights: Array<FloatArray>? = null

    fun fit(x: Array<FloatArray>, y: Array<FloatArray>) {
        weights = regression.fit(x, y)
    }

    fun isFitted(): Boolean = weights != null

    fun predict(features: FloatArray): Pair<Float, Float> {
        require(features.size == 4) { "Exactly four eye features are required." }
        require(features.all(Float::isFinite))
        val w = weights ?: error("Calibration model is not fitted.")
        val vector = floatArrayOf(1f, *features)
        return Pair(
            dot(vector, column(w, 0)).coerceIn(0f, 1f),
            dot(vector, column(w, 1)).coerceIn(0f, 1f),
        )
    }

    fun toFlatArray(): FloatArray {
        val w = weights ?: return FloatArray(0)
        return FloatArray(10) { index -> w[index / 2][index % 2] }
    }

    fun restore(flat: FloatArray): Boolean {
        if (flat.size != 10 || flat.any { !it.isFinite() }) return false
        weights = Array(5) { row -> FloatArray(2) { column -> flat[row * 2 + column] } }
        return true
    }

    fun clear() {
        weights = null
    }

    companion object {
        fun fromFlatArray(flat: FloatArray): RidgeCalibrationModelV2? {
            val model = RidgeCalibrationModelV2()
            return if (model.restore(flat)) model else null
        }
    }

    private fun column(matrix: Array<FloatArray>, index: Int): FloatArray =
        FloatArray(matrix.size) { matrix[it][index] }

    private fun dot(a: FloatArray, b: FloatArray): Float =
        a.indices.sumOf { (a[it] * b[it]).toDouble() }.toFloat()
}
