package com.eyecontrol.data.calibration

data class CalibrationFeatureSample(
    val leftIrisX: Float,
    val leftIrisY: Float,
    val rightIrisX: Float,
    val rightIrisY: Float,
    val targetX: Float,
    val targetY: Float,
) {
    fun features(): FloatArray = floatArrayOf(leftIrisX, leftIrisY, rightIrisX, rightIrisY)
}
