package com.eyecontrol.service

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/** Platform boundary for gaze-driven accessibility gestures. */
class TouchAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit
    override fun onInterrupt() = Unit
}
