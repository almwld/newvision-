package com.eyecontrol.domain.model

data class EyeFeatures(
    val leftIrisX: Float,
    val leftIrisY: Float,
    val rightIrisX: Float,
    val rightIrisY: Float,
) {
    fun toFloatArray(): FloatArray = floatArrayOf(leftIrisX, leftIrisY, rightIrisX, rightIrisY)
}
