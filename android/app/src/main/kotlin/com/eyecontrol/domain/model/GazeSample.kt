package com.eyecontrol.domain.model

data class GazeSample(
    val rawX: Float,
    val rawY: Float,
    val leftIrisX: Float,
    val leftIrisY: Float,
    val rightIrisX: Float,
    val rightIrisY: Float,
    val confidence: Float,
    val pupilDiameter: Float,
    val eyeOpen: Boolean,
    val timestampNs: Long,
) {
    fun eyeFeatures(): EyeFeatures = EyeFeatures(
        leftIrisX = leftIrisX,
        leftIrisY = leftIrisY,
        rightIrisX = rightIrisX,
        rightIrisY = rightIrisY,
    )
}
