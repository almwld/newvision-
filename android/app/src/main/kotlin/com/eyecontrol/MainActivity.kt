package com.eyecontrol

import android.Manifest
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import androidx.core.content.ContextCompat
import androidx.lifecycle.ProcessLifecycleOwner
import com.eyecontrol.core.constants.DwellConfiguration
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.data.camera.CameraController
import com.eyecontrol.data.repository.NativeGazeRepository
import com.eyecontrol.service.TouchAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val gazeRepository = NativeGazeRepository()
    private lateinit var cameraController: CameraController
    private var cameraRequested = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraController = CameraController(this, ProcessLifecycleOwner.get(), gazeRepository)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NativeConstants.PLATFORM_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "camera.start" -> {
                        if (
                            ContextCompat.checkSelfPermission(
                                this,
                                Manifest.permission.CAMERA,
                            ) != PackageManager.PERMISSION_GRANTED
                        ) {
                            result.error("CAMERA_PERMISSION", "Camera permission is required.", null)
                        } else {
                            cameraRequested = true
                            cameraController.start()
                            result.success(null)
                        }
                    }

                    "camera.stop" -> {
                        cameraRequested = false
                        cameraController.stop()
                        result.success(null)
                    }

                    "overlay.request" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            startActivity(
                                Intent(
                                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                    Uri.parse("package:$packageName"),
                                ),
                            )
                        }
                        result.success(null)
                    }

                    "overlay.isGranted" -> result.success(Settings.canDrawOverlays(this))

                    "accessibility.request" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }

                    "accessibility.isEnabled" -> result.success(isAccessibilityEnabled())

                    "gesture.tap" -> {
                        val x = call.argument<Double>("x")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT",
                                "Missing x.",
                                null,
                            )
                        val y = call.argument<Double>("y")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT",
                                "Missing y.",
                                null,
                            )
                        if (!TouchAccessibilityService.performTap(x.toFloat(), y.toFloat())) {
                            result.error(
                                "ACCESSIBILITY_UNAVAILABLE",
                                "Accessibility service is not enabled.",
                                null,
                            )
                        } else {
                            result.success(null)
                        }
                    }

                    "dwell.configure" -> {
                        val duration = call.argument<Int>("durationMs")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT",
                                "Missing durationMs.",
                                null,
                            )
                        val radius = call.argument<Double>("radiusPx")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT",
                                "Missing radiusPx.",
                                null,
                            )
                        DwellConfiguration.configure(duration.toLong(), radius.toFloat())
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                AppLogger.e("Platform call failed: " + call.method, error)
                result.error("PLATFORM_ERROR", error.message, null)
            }
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = getSystemService(AccessibilityManager::class.java) ?: return false
        val expected = ComponentName(this, TouchAccessibilityService::class.java)
        return manager
            .getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
            .any { service -> service.resolveInfo.serviceInfo.componentName == expected }
    }

    override fun onPause() {
        cameraController.stop()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (cameraRequested) cameraController.start()
    }

    override fun onDestroy() {
        cameraController.close()
        super.onDestroy()
    }
}
