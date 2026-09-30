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
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.eyecontrol.core.constants.DwellConfiguration
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.calibration.CalibrationSample
import com.eyecontrol.data.calibration.CalibrationStore
import com.eyecontrol.data.camera.CameraController
import com.eyecontrol.data.repository.NativeGazeRepository
import com.eyecontrol.domain.model.GazeFrame
import com.eyecontrol.domain.usecase.DwellController
import com.eyecontrol.service.HapticFeedback
import com.eyecontrol.service.OverlayCursorService
import com.eyecontrol.service.TouchAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private lateinit var gazeRepository: NativeGazeRepository
    private lateinit var calibrationManager: CalibrationManager
    private lateinit var cameraController: CameraController
    private lateinit var dwellController: DwellController
    private lateinit var hapticFeedback: HapticFeedback
    private var cameraRequested = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        calibrationManager = CalibrationManager(CalibrationStore(this))
        gazeRepository = NativeGazeRepository(
            calibrationManager = calibrationManager,
            screenWidth = resources.displayMetrics.widthPixels,
            screenHeight = resources.displayMetrics.heightPixels,
        )
        cameraController = CameraController(this, ProcessLifecycleOwner.get(), gazeRepository)
        hapticFeedback = HapticFeedback(this)
        dwellController = DwellController(onDwell = ::performDwellTap)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.RESUMED) {
                gazeRepository.latestScreenPoint().collectLatest { point ->
                    if (point == null || point.isBlinking) return@collectLatest
                    OverlayCursorService.updatePosition(
                        point.xPx.toInt() - 14,
                        point.yPx.toInt() - 14,
                    )
                    dwellController.update(
                        GazeFrame(
                            x = point.xPx,
                            y = point.yPx,
                            confidence = point.confidence,
                            timestampMs = point.timestampNs / 1_000_000L,
                            blinking = false,
                        ),
                    )
                }
            }
        }
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
                            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) !=
                            PackageManager.PERMISSION_GRANTED
                        ) {
                            result.error("CAMERA_PERMISSION", "Camera permission is required.", null)
                        } else {
                            cameraRequested = true
                            startOverlayIfPermitted()
                            cameraController.start()
                            result.success(null)
                        }
                    }
                    "camera.stop" -> {
                        cameraRequested = false
                        cameraController.stop()
                        gazeRepository.reset()
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
                    "gaze.latest" -> {
                        val sample = gazeRepository.latest.value
                        if (sample == null) {
                            result.success(null)
                        } else {
                            result.success(
                                mapOf(
                                    "x" to sample.rawX.toDouble(),
                                    "y" to sample.rawY.toDouble(),
                                    "leftIrisX" to sample.leftIrisX.toDouble(),
                                    "leftIrisY" to sample.leftIrisY.toDouble(),
                                    "rightIrisX" to sample.rightIrisX.toDouble(),
                                    "rightIrisY" to sample.rightIrisY.toDouble(),
                                    "confidence" to sample.confidence.toDouble(),
                                    "timestampMs" to sample.timestampNs / 1_000_000L,
                                    "blinking" to !sample.eyeOpen,
                                ),
                            )
                        }
                    }
                    "screen.size" -> result.success(
                        mapOf(
                            "width" to resources.displayMetrics.widthPixels,
                            "height" to resources.displayMetrics.heightPixels,
                        ),
                    )
                    "calibration.isReady" -> result.success(calibrationManager.hasActiveModel())
                    "calibration.fit" -> {
                        @Suppress("UNCHECKED_CAST")
                        val rawSamples = call.argument<List<Map<String, Any?>>>("samples")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing calibration samples.", null,
                            )
                        if (rawSamples.size < 9) {
                            return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Nine calibration samples are required.", null,
                            )
                        }
                        val samples = rawSamples.map { sample ->
                            CalibrationSample(
                                x = (sample["x"] as Number).toFloat(),
                                y = (sample["y"] as Number).toFloat(),
                                targetX = (sample["targetX"] as Number).toFloat(),
                                targetY = (sample["targetY"] as Number).toFloat(),
                            )
                        }
                        calibrationManager.fit(samples)
                        result.success(null)
                    }
                    "calibration.predict" -> {
                        val x = call.argument<Double>("x")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing x.", null,
                            )
                        val y = call.argument<Double>("y")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing y.", null,
                            )
                        if (!calibrationManager.hasActiveModel()) {
                            return@setMethodCallHandler result.error(
                                "CALIBRATION_REQUIRED", "Calibration has not been completed.", null,
                            )
                        }
                        val point = calibrationManager.predict(x.toFloat(), y.toFloat())
                        result.success(mapOf("x" to point.first, "y" to point.second))
                    }
                    "calibration.clear" -> {
                        calibrationManager.clear()
                        gazeRepository.reset()
                        result.success(null)
                    }
                    "gesture.tap" -> {
                        val x = call.argument<Double>("x")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing x.", null,
                            )
                        val y = call.argument<Double>("y")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing y.", null,
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
                                "INVALID_ARGUMENT", "Missing durationMs.", null,
                            )
                        val radius = call.argument<Double>("radiusPx")
                            ?: return@setMethodCallHandler result.error(
                                "INVALID_ARGUMENT", "Missing radiusPx.", null,
                            )
                        DwellConfiguration.configure(duration.toLong(), radius.toFloat())
                        dwellController.configure(duration.toLong(), radius.toFloat())
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

    private fun startOverlayIfPermitted() {
        if (Settings.canDrawOverlays(this)) {
            startService(Intent(this, OverlayCursorService::class.java))
        }
    }

    private fun performDwellTap(x: Float, y: Float) {
        if (TouchAccessibilityService.performTap(x, y)) hapticFeedback.click()
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = getSystemService(AccessibilityManager::class.java) ?: return false
        val expected = ComponentName(this, TouchAccessibilityService::class.java)
        return manager
            .getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
            .any { service ->
                val info = service.resolveInfo.serviceInfo
                ComponentName(info.packageName, info.name) == expected
            }
    }

    override fun onPause() {
        cameraController.stop()
        stopService(Intent(this, OverlayCursorService::class.java))
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (cameraRequested) {
            startOverlayIfPermitted()
            cameraController.start()
        }
    }

    override fun onDestroy() {
        cameraController.close()
        super.onDestroy()
    }
}
