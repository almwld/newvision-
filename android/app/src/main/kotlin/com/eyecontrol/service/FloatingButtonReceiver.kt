package com.eyecontrol.service

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat

class FloatingButtonReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            FloatingButtonService.ACTION_TOGGLE -> {
                if (TrackingForegroundService.isRunning) {
                    context.stopService(Intent(context, TrackingForegroundService::class.java))
                } else if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                    ContextCompat.startForegroundService(
                        context,
                        Intent(context, TrackingForegroundService::class.java),
                    )
                }
            }
            FloatingButtonService.ACTION_EMERGENCY -> {
                context.stopService(Intent(context, TrackingForegroundService::class.java))
                context.stopService(Intent(context, OverlayCursorService::class.java))
            }
            FloatingButtonService.ACTION_TAP_CENTER -> {
                val service = TouchAccessibilityService.getInstance()
                val x = context.resources.displayMetrics.widthPixels * 0.5f
                val y = context.resources.displayMetrics.heightPixels * 0.5f
                service?.let { TouchAccessibilityService.performTap(x, y) }
            }
            FloatingButtonService.ACTION_SCROLL_UP -> {
                TouchAccessibilityService.getInstance()?.scrollUp()
            }
            FloatingButtonService.ACTION_SCROLL_DOWN -> {
                TouchAccessibilityService.getInstance()?.scrollDown()
            }
        }
    }
}
