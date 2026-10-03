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
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.eyecontrol.core.constants.DwellConfiguration
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.data.calibration.CalibrationFeatureSample
import com.eyecontrol.data.calibration.CalibrationSample
import com.eyecontrol.data.camera.TrackingRuntime
import com.eyecontrol.data.repository.NativeCalibrationRepository
import com.eyecontrol.data.repository.NativeGazeRepository
import com.eyecontrol.data.repository.NativeGazeRepositoryFactory
import com.eyecontrol.data.settings.GazeZoneDetector
import com.eyecontrol.data.settings.GazeZoneSettings
import com.eyecontrol.data.settings.GazeZone
import com.eyecontrol.data.settings.SettingsStorage
import com.eyecontrol.data.settings.ZoneActivationResult
import com.eyecontrol.data.settings.ZoneActivationTracker
import com.eyecontrol.domain.usecase.DwellController
import com.eyecontrol.service.HapticFeedback
import com.eyecontrol.service.OverlayCursorService
import com.eyecontrol.service.TouchAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private lateinit var gazeRepository: NativeGazeRepository
    private lateinit var calibrationRepository: NativeCalibrationRepository
    private lateinit var repositoryFactory: NativeGazeRepositoryFactory
    private lateinit var dwellController: DwellController
    private lateinit var hapticFeedback: HapticFeedback
    private lateinit var settingsStorage: SettingsStorage
    private var currentSettings = GazeZoneSettings()
    private lateinit var zoneDetector: GazeZoneDetector
    private lateinit var zoneTracker: ZoneActivationTracker
    private var cameraRequested = false
    private var gazeEventJob: Job? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        repositoryFactory = NativeGazeRepositoryFactory(this)
        calibrationRepository = repositoryFactory.calibrationRepository()
        TrackingRuntime.initialize(this)
        gazeRepository = TrackingRuntime.repository
        hapticFeedback = HapticFeedback(this)
        settingsStorage = SettingsStorage(getSharedPreferences("newvision", MODE_PRIVATE))
        currentSettings = settingsStorage.load()
        val screenWidth = resources.displayMetrics.widthPixels
        val screenHeight = resources.displayMetrics.heightPixels
        zoneDetector = GazeZoneDetector(screenWidth, screenHeight) { currentSettings }
        zoneTracker = ZoneActivationTracker(currentSettings.activationMs, currentSettings.cooldownMs)
        dwellController = DwellController(
            durationMs = dwellDuration(currentSettings),
            radiusPx = NativeConstants.DWELL_RADIUS_PX,
            onDwell = ::performDwellTap,
        )
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.RESUMED) {
                gazeRepository.latestScreenPoint().collectLatest { point ->
                    if (point == null || point.isBlinking) return@collectLatest
                    OverlayCursorService.update(point)
                    val zone = zoneDetector.detect(point)
                    if (zone == null) {
                        zoneTracker.reset()
                        dwellController.update(point)
                    } else {
                        dwellController.reset()
                        if (zoneTracker.update(zone) is ZoneActivationResult.Activated) {
                            performZoneAction(zone)
                        }
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.eyecontrol/gaze_screen_point",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                gazeEventJob?.cancel()
                gazeEventJob = lifecycleScope.launch {
                    gazeRepository.latestScreenPoint().collectLatest { point ->
                        if (point != null) {
                            events?.success(
                                mapOf(
                                    "xPx" to point.xPx.toDouble(),
                                    "yPx" to point.yPx.toDouble(),
                                    "confidence" to point.confidence.toDouble(),
                                    "isBlinking" to point.isBlinking,
                                    "timestampNs" to point.timestampNs,
                                ),
                            )
                        }
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                gazeEventJob?.cancel()
                gazeEventJob = null
            }
        })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NativeConstants.PLATFORM_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "camera.start" -> {
                            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                                result.error("CAMERA_PERMISSION", "Camera permission is required.", null)
                            } else {
                                cameraRequested = true
                                startTrackingService()
                                result.success(null)
                            }
                        }
                        "camera.stop" -> {
                            cameraRequested = false
                            stopTrackingService()
                            gazeRepository.reset()
                            result.success(null)
                        }
                        "overlay.request" -> {
                            if (!Settings.canDrawOverlays(this)) {
                                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                            }
                            result.success(null)
                        }
                        "overlay.isGranted" -> result.success(Settings.canDrawOverlays(this))
                        "floating.show" -> {
                            if (!Settings.canDrawOverlays(this)) {
                                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                                result.success(false)
                            } else {
                                ContextCompat.startForegroundService(this, Intent(this, com.eyecontrol.service.FloatingButtonService::class.java))
                                result.success(true)
                            }
                        }
                        "floating.hide" -> {
                            stopService(Intent(this, com.eyecontrol.service.FloatingButtonService::class.java))
                            result.success(true)
                        }
                        "floating.isRunning" -> result.success(com.eyecontrol.service.FloatingButtonService.isRunning)\n                        "floating.show" -> {\n                            if (!Settings.canDrawOverlays(this)) {\n                                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))\n                                result.success(false)\n                            } else {\n                                ContextCompat.startForegroundService(this, Intent(this, com.eyecontrol.service.FloatingButtonService::class.java))\n                                result.success(true)\n                            }\n                        }\n                        "floating.hide" -> {\n                            stopService(Intent(this, com.eyecontrol.service.FloatingButtonService::class.java))\n                            result.success(true)\n                        }\n                        "floating.isRunning" -> result.success(com.eyecontrol.service.FloatingButtonService.isRunning)
                        "accessibility.request" -> {
                            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                            result.success(null)
                        }
                        "accessibility.isEnabled" -> result.success(isAccessibilityEnabled())
                        "gaze.latest" -> {
                            val sample = gazeRepository.latest.value
                            result.success(
                                sample?.let {
                                    mapOf(
                                        "x" to it.rawX.toDouble(),
                                        "y" to it.rawY.toDouble(),
                                        "leftIrisX" to it.leftIrisX.toDouble(),
                                        "leftIrisY" to it.leftIrisY.toDouble(),
                                        "rightIrisX" to it.rightIrisX.toDouble(),
                                        "rightIrisY" to it.rightIrisY.toDouble(),
                                        "confidence" to it.confidence.toDouble(),
                                        "timestampMs" to it.timestampNs / 1_000_000L,
                                        "blinking" to !it.eyeOpen,
                                    )
                                },
                            )
                        }
                        "screen.size" -> result.success(mapOf(
                            "width" to resources.displayMetrics.widthPixels,
                            "height" to resources.displayMetrics.heightPixels,
                        ))
                        "calibration.isReady" -> result.success(calibrationRepository.hasActiveModel())
                        "calibration.fit" -> {
                            @Suppress("UNCHECKED_CAST")
                            val rawSamples = call.argument<List<Map<String, Any?>>>("samples")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing calibration samples.", null)
                            if (rawSamples.size < 9) {
                                return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Nine calibration samples are required.", null)
                            }
                            val useV2 = rawSamples.all {
                                it["leftIrisX"] is Number && it["leftIrisY"] is Number &&
                                    it["rightIrisX"] is Number && it["rightIrisY"] is Number
                            }
                            if (useV2) {
                                calibrationRepository.fitV2(rawSamples.map {
                                    CalibrationFeatureSample(
                                        leftIrisX = (it["leftIrisX"] as Number).toFloat(),
                                        leftIrisY = (it["leftIrisY"] as Number).toFloat(),
                                        rightIrisX = (it["rightIrisX"] as Number).toFloat(),
                                        rightIrisY = (it["rightIrisY"] as Number).toFloat(),
                                        targetX = (it["targetX"] as Number).toFloat(),
                                        targetY = (it["targetY"] as Number).toFloat(),
                                    )
                                })
                            } else {
                                calibrationRepository.fitLegacy(rawSamples.map {
                                    CalibrationSample(
                                        x = (it["x"] as Number).toFloat(),
                                        y = (it["y"] as Number).toFloat(),
                                        targetX = (it["targetX"] as Number).toFloat(),
                                        targetY = (it["targetY"] as Number).toFloat(),
                                    )
                                })
                            }
                            result.success(null)
                        }
                        "calibration.predict" -> {
                            val x = call.argument<Double>("x")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing x.", null)
                            val y = call.argument<Double>("y")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing y.", null)
                            if (!calibrationRepository.hasActiveModel()) {
                                return@setMethodCallHandler result.error("CALIBRATION_REQUIRED", "Calibration has not been completed.", null)
                            }
                            val point = calibrationRepository.predict(x.toFloat(), y.toFloat())
                            result.success(mapOf("x" to point.first, "y" to point.second))
                        }
                        "calibration.clear" -> {
                            calibrationRepository.clearNow()
                            gazeRepository.reset()
                            result.success(null)
                        }
                        "gesture.tap" -> {
                            val x = call.argument<Double>("x")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing x.", null)
                            val y = call.argument<Double>("y")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing y.", null)
                            if (!TouchAccessibilityService.performTap(x.toFloat(), y.toFloat())) {
                                result.error("ACCESSIBILITY_UNAVAILABLE", "Accessibility service is not enabled.", null)
                            } else result.success(null)
                        }
                        "settings.getGazeZones" -> result.success(settingsMap(currentSettings))
                        "settings.setGazeZones" -> {
                            currentSettings = settingsFromCall(call)
                            settingsStorage.save(currentSettings)
                            zoneTracker.configure(currentSettings.activationMs, currentSettings.cooldownMs)
                            dwellController.configure(dwellDuration(currentSettings), NativeConstants.DWELL_RADIUS_PX)
                            result.success(settingsMap(currentSettings))
                        }
                        "settings.resetGazeZones" -> {
                            currentSettings = settingsStorage.reset()
                            zoneTracker.configure(currentSettings.activationMs, currentSettings.cooldownMs)
                            dwellController.configure(dwellDuration(currentSettings), NativeConstants.DWELL_RADIUS_PX)
                            result.success(settingsMap(currentSettings))
                        }
                        "dwell.configure" -> {
                            val duration = call.argument<Int>("durationMs")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing durationMs.", null)
                            val radius = call.argument<Double>("radiusPx")
                                ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "Missing radiusPx.", null)
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


    private fun dwellDuration(settings: GazeZoneSettings): Long =
        if (settings.fastClickEnabled) settings.fastClickMs else NativeConstants.DWELL_DURATION_MS

    private fun settingsMap(settings: GazeZoneSettings): Map<String, Any> = mapOf(
        "enabled" to settings.enabled,
        "scrollUpEnabled" to settings.scrollUpEnabled,
        "scrollDownEnabled" to settings.scrollDownEnabled,
        "scrollLeftEnabled" to settings.scrollLeftEnabled,
        "scrollRightEnabled" to settings.scrollRightEnabled,
        "fastClickEnabled" to settings.fastClickEnabled,
        "edgeThreshold" to settings.edgeThreshold.toDouble(),
        "activationMs" to settings.activationMs,
        "cooldownMs" to settings.cooldownMs,
        "fastClickMs" to settings.fastClickMs,
    )

    private fun settingsFromCall(call: MethodCall): GazeZoneSettings {
        fun bool(name: String, fallback: Boolean) = call.argument<Boolean>(name) ?: fallback
        fun long(name: String, fallback: Long) = call.argument<Number>(name)?.toLong() ?: fallback
        fun edge(name: String, fallback: Float) = call.argument<Number>(name)?.toFloat() ?: fallback
        return GazeZoneSettings(
            enabled = bool("enabled", currentSettings.enabled),
            scrollUpEnabled = bool("scrollUpEnabled", currentSettings.scrollUpEnabled),
            scrollDownEnabled = bool("scrollDownEnabled", currentSettings.scrollDownEnabled),
            scrollLeftEnabled = bool("scrollLeftEnabled", currentSettings.scrollLeftEnabled),
            scrollRightEnabled = bool("scrollRightEnabled", currentSettings.scrollRightEnabled),
            fastClickEnabled = bool("fastClickEnabled", currentSettings.fastClickEnabled),
            edgeThreshold = edge("edgeThreshold", currentSettings.edgeThreshold),
            activationMs = long("activationMs", currentSettings.activationMs),
            cooldownMs = long("cooldownMs", currentSettings.cooldownMs),
            fastClickMs = long("fastClickMs", currentSettings.fastClickMs),
        )
    }

    private fun performZoneAction(zone: GazeZone) {
        val service = TouchAccessibilityService.getInstance()
        val success = when (zone) {
            GazeZone.TOP -> service?.scrollUp() ?: false
            GazeZone.BOTTOM -> service?.scrollDown() ?: false
            GazeZone.LEFT -> service?.scrollLeft() ?: false
            GazeZone.RIGHT -> service?.scrollRight() ?: false
        }
        if (success) hapticFeedback.click()
        AppLogger.i("Gaze zone " + zone.name + ": " + if (success) "activated" else "accessibility unavailable")
    }

    private fun startTrackingService() {
        ContextCompat.startForegroundService(
            this,
            Intent(this, com.eyecontrol.service.TrackingForegroundService::class.java),
        )
    }

    private fun stopTrackingService() {
        stopService(Intent(this, com.eyecontrol.service.TrackingForegroundService::class.java))
    }

    private fun performDwellTap(x: Float, y: Float) {
        if (TouchAccessibilityService.performTap(x, y)) hapticFeedback.click()
    }

    private fun isAccessibilityEnabled(): Boolean {
        val manager = getSystemService(AccessibilityManager::class.java) ?: return false
        val expected = ComponentName(this, TouchAccessibilityService::class.java)
        return manager.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
            .any { service ->
                val info = service.resolveInfo.serviceInfo
                ComponentName(info.packageName, info.name) == expected
            }
    }

    override fun onPause() {
        // TrackingForegroundService owns the camera; Activity lifecycle must not stop it.
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (cameraRequested && !com.eyecontrol.service.TrackingForegroundService.isRunning) {
            startTrackingService()
        }
    }

    override fun onDestroy() {
        gazeEventJob?.cancel()
        super.onDestroy()
    }
}
