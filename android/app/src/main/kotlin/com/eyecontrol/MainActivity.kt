package com.eyecontrol

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.ContextCompat
import androidx.lifecycle.ProcessLifecycleOwner
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NativeConstants.PLATFORM_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "camera.start" -> {
                            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
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
                        "gesture.tap" -> {
                            val x = call.argument<Double>("x")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing x.", null)
                            val y = call.argument<Double>("y")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing y.", null)
                            if (!TouchAccessibilityService.performTap(x.toFloat(), y.toFloat())) {
                                result.error("ACCESSIBILITY_UNAVAILABLE", "Accessibility service is not enabled.", null)
                            } else {
                                result.success(null)
                            }
                        }
                        "dwell.configure" -> result.success(null)
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    AppLogger.e("Platform call failed: ${call.method}", error)
                    result.error("PLATFORM_ERROR", error.message, null)
                }
            }
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
