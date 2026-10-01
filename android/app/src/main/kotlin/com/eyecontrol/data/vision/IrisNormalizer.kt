package com.eyecontrol.data.vision

import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import kotlin.math.hypot

class IrisNormalizer {
    fun normalize(
        iris: List<NormalizedLandmark>,
        eyeCorners: Pair<NormalizedLandmark, NormalizedLandmark>,
    ): Pair<Float, Float>? {
        if (iris.isEmpty()) return null
        val centerX = iris.sumOf { it.x().toDouble() }.toFloat() / iris.size
        val centerY = iris.sumOf { it.y().toDouble() }.toFloat() / iris.size
        val dx = eyeCorners.second.x() - eyeCorners.first.x()
        val dy = eyeCorners.second.y() - eyeCorners.first.y()
        val width = hypot(dx.toDouble(), dy.toDouble()).toFloat()
        if (width < 1e-4f) return null
        val originX = eyeCorners.first.x()
        val originY = eyeCorners.first.y()
        return Pair(
            ((centerX - originX) / width).coerceIn(-1f, 2f),
            ((centerY - originY) / width).coerceIn(-1f, 2f),
        )
    }
}
