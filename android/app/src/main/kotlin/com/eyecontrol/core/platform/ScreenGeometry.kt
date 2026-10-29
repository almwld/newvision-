package com.eyecontrol.core.platform

import android.content.Context
import android.util.DisplayMetrics
import android.view.WindowManager

/**
 * Uses the physical display coordinate space shared by Accessibility gestures,
 * calibration targets, and system-overlay windows. App-window metrics can exclude
 * system bars, causing gaze clicks to drift vertically outside the app.
 */
object ScreenGeometry {
    @Suppress("DEPRECATION")
    fun realMetrics(context: Context): DisplayMetrics {
        val metrics = DisplayMetrics()
        val manager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        manager.defaultDisplay.getRealMetrics(metrics)
        return metrics
    }
}
