package com.eyecontrol.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import com.eyecontrol.core.platform.ScreenGeometry
import java.util.concurrent.atomic.AtomicReference

/**
 * Executes real system-wide touch gestures through Android Accessibility.
 * These gestures work in the foreground app, not only inside NewVision.
 */
class TouchAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        super.onServiceConnected()
        instance.set(this)
    }

    override fun onDestroy() {
        instance.compareAndSet(this, null)
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit
    override fun onInterrupt() = Unit

    private fun dispatchSwipe(
        startX: Float,
        startY: Float,
        endX: Float,
        endY: Float,
    ): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val path = Path().apply {
            moveTo(startX, startY)
            lineTo(endX, endY)
        }
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0L, SWIPE_DURATION_MS))
            .build()
        return dispatchGesture(gesture, null, null)
    }

    private fun tap(x: Float, y: Float): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val path = Path().apply { moveTo(x, y) }
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0L, TAP_DURATION_MS))
            .build()
        return dispatchGesture(gesture, null, null)
    }

    // Direction names match the physical gesture performed on the screen.
    fun scrollUp(): Boolean {
        val metrics = ScreenGeometry.realMetrics(this)
        val width = metrics.widthPixels.toFloat()
        val height = metrics.heightPixels.toFloat()
        return dispatchSwipe(width * 0.5f, height * 0.72f, width * 0.5f, height * 0.28f)
    }

    fun scrollDown(): Boolean {
        val metrics = resources.displayMetrics
        val width = metrics.widthPixels.toFloat()
        val height = metrics.heightPixels.toFloat()
        return dispatchSwipe(width * 0.5f, height * 0.28f, width * 0.5f, height * 0.72f)
    }

    fun scrollLeft(): Boolean {
        val metrics = resources.displayMetrics
        val width = metrics.widthPixels.toFloat()
        val height = metrics.heightPixels.toFloat()
        return dispatchSwipe(width * 0.72f, height * 0.5f, width * 0.28f, height * 0.5f)
    }

    fun scrollRight(): Boolean {
        val metrics = resources.displayMetrics
        val width = metrics.widthPixels.toFloat()
        val height = metrics.heightPixels.toFloat()
        return dispatchSwipe(width * 0.28f, height * 0.5f, width * 0.72f, height * 0.5f)
    }

    companion object {
        private const val SWIPE_DURATION_MS = 300L
        private const val TAP_DURATION_MS = 80L
        private val instance = AtomicReference<TouchAccessibilityService?>()

        fun getInstance(): TouchAccessibilityService? = instance.get()

        fun performTap(x: Float, y: Float): Boolean = instance.get()?.tap(x, y) == true
    }
}
