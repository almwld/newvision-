package com.eyecontrol.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import java.util.concurrent.atomic.AtomicReference

class TouchAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        instance.set(this)
        super.onServiceConnected()
    }

    override fun onDestroy() {
        instance.compareAndSet(this, null)
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit
    override fun onInterrupt() = Unit

    private fun tap(x: Float, y: Float): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val path = Path().apply { moveTo(x, y) }
        return dispatchGesture(
            GestureDescription.Builder()
                .addStroke(GestureDescription.StrokeDescription(path, 0L, 80L))
                .build(),
            null,
            null,
        )
    }

    companion object {
        private val instance = AtomicReference<TouchAccessibilityService?>()
        fun performTap(x: Float, y: Float): Boolean = instance.get()?.tap(x, y) == true
    }
}
