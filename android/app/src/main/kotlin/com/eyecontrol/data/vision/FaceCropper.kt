package com.eyecontrol.data.vision

import android.graphics.Bitmap
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark

object FaceCropper {
    fun cropFace(
        bitmap: Bitmap,
        landmarks: List<NormalizedLandmark>,
        padding: Float = 0.30f,
    ): Bitmap? {
        if (bitmap.isRecycled || landmarks.isEmpty()) return null

        var minX = 1f
        var minY = 1f
        var maxX = 0f
        var maxY = 0f
        for (landmark in landmarks) {
            minX = minOf(minX, landmark.x())
            minY = minOf(minY, landmark.y())
            maxX = maxOf(maxX, landmark.x())
            maxY = maxOf(maxY, landmark.y())
        }

        val left = (minX * bitmap.width).toInt().coerceIn(0, bitmap.width)
        val top = (minY * bitmap.height).toInt().coerceIn(0, bitmap.height)
        val right = (maxX * bitmap.width).toInt().coerceIn(0, bitmap.width)
        val bottom = (maxY * bitmap.height).toInt().coerceIn(0, bitmap.height)
        val width = right - left
        val height = bottom - top
        if (width <= 0 || height <= 0) return null

        val padX = (width * padding).toInt()
        val padY = (height * padding).toInt()
        val safeLeft = (left - padX).coerceAtLeast(0)
        val safeTop = (top - padY).coerceAtLeast(0)
        val safeRight = (right + padX).coerceAtMost(bitmap.width)
        val safeBottom = (bottom + padY).coerceAtMost(bitmap.height)
        val safeWidth = safeRight - safeLeft
        val safeHeight = safeBottom - safeTop
        if (safeWidth <= 0 || safeHeight <= 0) return null

        return Bitmap.createBitmap(bitmap, safeLeft, safeTop, safeWidth, safeHeight)
    }
}
