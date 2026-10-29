package com.eyecontrol.service

import android.Manifest
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.eyecontrol.MainActivity
import com.eyecontrol.data.camera.TrackingRuntime
import com.eyecontrol.core.platform.ScreenGeometry

class FloatingButtonReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            FloatingButtonService.ACTION_TOGGLE -> toggleTracking(context)
            FloatingButtonService.ACTION_EMERGENCY -> {
                context.stopService(Intent(context, TrackingForegroundService::class.java))
                context.stopService(Intent(context, OverlayCursorService::class.java))
                Toast.makeText(context, "تم إيقاف التحكم بالعين", Toast.LENGTH_SHORT).show()
            }
            FloatingButtonService.ACTION_TAP_CENTER -> {
                if (!ensureAccessibility(context)) return
                val metrics = ScreenGeometry.realMetrics(context)
                val x = metrics.widthPixels * 0.5f
                val y = metrics.heightPixels * 0.5f
                if (!TouchAccessibilityService.performTap(x, y)) {
                    Toast.makeText(context, "تعذر تنفيذ النقرة؛ تحقق من خدمة إمكانية الوصول", Toast.LENGTH_SHORT).show()
                }
            }
            FloatingButtonService.ACTION_SCROLL_UP -> performScroll(context) { it.scrollUp() }
            FloatingButtonService.ACTION_SCROLL_DOWN -> performScroll(context) { it.scrollDown() }
            FloatingButtonService.ACTION_SCROLL_LEFT -> performScroll(context) { it.scrollLeft() }
            FloatingButtonService.ACTION_SCROLL_RIGHT -> performScroll(context) { it.scrollRight() }
        }
    }

    private fun toggleTracking(context: Context) {
        if (TrackingForegroundService.isRunning) {
            context.stopService(Intent(context, TrackingForegroundService::class.java))
            context.stopService(Intent(context, OverlayCursorService::class.java))
            Toast.makeText(context, "تم إيقاف تتبع النظر", Toast.LENGTH_SHORT).show()
            return
        }
        if (!Settings.canDrawOverlays(context)) {
            Toast.makeText(context, "اسمح لـ NewVision بالظهور فوق التطبيقات أولاً", Toast.LENGTH_LONG).show()
            context.startActivity(
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${context.packageName}"),
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            return
        }
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(context, "افتح NewVision وامنح صلاحية الكاميرا أولاً", Toast.LENGTH_LONG).show()
            openApp(context)
            return
        }
        TrackingRuntime.initialize(context)
        if (!TrackingRuntime.calibrationRepository.hasActiveModel()) {
            Toast.makeText(context, "أكمل معايرة النظر داخل NewVision أولاً", Toast.LENGTH_LONG).show()
            openApp(context)
            return
        }
        if (!isAccessibilityEnabled(context)) {
            Toast.makeText(context, "فعّل خدمة NewVision للتحكم بالنقر والتمرير", Toast.LENGTH_LONG).show()
            context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            return
        }
        try {
            ContextCompat.startForegroundService(context, Intent(context, TrackingForegroundService::class.java))
            Toast.makeText(context, "جارٍ تشغيل تتبع النظر", Toast.LENGTH_SHORT).show()
        } catch (error: Exception) {
            Toast.makeText(context, "تعذر التشغيل من الخلفية. افتح NewVision وابدأ التتبع مرة واحدة: ${error.message}", Toast.LENGTH_LONG).show()
            openApp(context)
        }
    }

    private fun performScroll(context: Context, action: (TouchAccessibilityService) -> Boolean) {
        if (!ensureAccessibility(context)) return
        val service = TouchAccessibilityService.getInstance()
        if (service == null || !action(service)) {
            Toast.makeText(context, "تعذر تنفيذ التمرير", Toast.LENGTH_SHORT).show()
        }
    }

    private fun ensureAccessibility(context: Context): Boolean {
        if (isAccessibilityEnabled(context) && TouchAccessibilityService.getInstance() != null) return true
        Toast.makeText(context, "فعّل خدمة NewVision من إعدادات إمكانية الوصول", Toast.LENGTH_LONG).show()
        context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        return false
    }

    private fun isAccessibilityEnabled(context: Context): Boolean {
        val manager = context.getSystemService(AccessibilityManager::class.java) ?: return false
        val expected = ComponentName(context, TouchAccessibilityService::class.java)
        return manager.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK).any {
            val info = it.resolveInfo.serviceInfo
            ComponentName(info.packageName, info.name) == expected
        }
    }

    private fun openApp(context: Context) {
        context.startActivity(Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        })
    }
}