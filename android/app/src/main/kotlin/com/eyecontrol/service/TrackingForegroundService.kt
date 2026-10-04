package com.eyecontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.eyecontrol.MainActivity
import com.eyecontrol.R
import com.eyecontrol.data.camera.CameraController
import com.eyecontrol.data.camera.TrackingRuntime
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.data.settings.GazeZoneDetector
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import com.eyecontrol.data.settings.GazeZone
import com.eyecontrol.data.settings.SettingsStorage
import com.eyecontrol.data.settings.ZoneActivationResult
import com.eyecontrol.data.settings.ZoneActivationTracker
import com.eyecontrol.domain.usecase.DwellController

/**
 * Owns the CameraX pipeline so tracking is independent from MainActivity.
 */
class TrackingForegroundService : LifecycleService() {
    companion object {
        private const val CHANNEL_ID = "newvision_tracking"
        private const val NOTIFICATION_ID = 1002

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private var cameraController: CameraController? = null
    private lateinit var settingsStorage: SettingsStorage
    private lateinit var zoneDetector: GazeZoneDetector
    private lateinit var zoneTracker: ZoneActivationTracker
    private lateinit var dwellController: DwellController
    private lateinit var hapticFeedback: HapticFeedback

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        TrackingRuntime.initialize(this)
        createChannel()
        startAsForeground()
        settingsStorage = SettingsStorage(getSharedPreferences("newvision", MODE_PRIVATE))
        val settings = settingsStorage.load()
        zoneDetector = GazeZoneDetector(
            resources.displayMetrics.widthPixels,
            resources.displayMetrics.heightPixels,
        ) { settingsStorage.load() }
        zoneTracker = ZoneActivationTracker(settings.activationMs, settings.cooldownMs)
        hapticFeedback = HapticFeedback(this)
        dwellController = DwellController(
            durationMs = if (settings.fastClickEnabled) settings.fastClickMs else NativeConstants.DWELL_DURATION_MS,
            radiusPx = NativeConstants.DWELL_RADIUS_PX,
            onDwell = ::performDwellTap,
        )
        cameraController = CameraController(this, this, TrackingRuntime.repository)
        cameraController?.start()
        startGazeControlLoop()
        if (android.provider.Settings.canDrawOverlays(this)) {
            startService(Intent(this, OverlayCursorService::class.java))
        }
    }

    private fun startAsForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "NewVision Tracking",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = "تشغيل تتبع العين في الخلفية"
                },
            )
        }
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pending = android.app.PendingIntent.getActivity(
            this,
            2,
            intent,
            android.app.PendingIntent.FLAG_IMMUTABLE or
                android.app.PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_eye)
            .setContentTitle("NewVision نشط")
            .setContentText("تتبع العين يعمل في الخلفية")
            .setContentIntent(pending)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun startGazeControlLoop() {
        lifecycleScope.launch {
            TrackingRuntime.repository.latestScreenPoint().collectLatest { point ->
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

    private fun performZoneAction(zone: GazeZone) {
        val service = TouchAccessibilityService.getInstance()
        val success = when (zone) {
            GazeZone.TOP -> service?.scrollUp() ?: false
            GazeZone.BOTTOM -> service?.scrollDown() ?: false
            GazeZone.LEFT -> service?.scrollLeft() ?: false
            GazeZone.RIGHT -> service?.scrollRight() ?: false
        }
        if (success) hapticFeedback.click()
        com.eyecontrol.core.logging.AppLogger.i(
            "Background gaze zone " + zone.name + ": " +
                if (success) "activated" else "accessibility unavailable",
        )
    }

    private fun performDwellTap(x: Float, y: Float) {
        if (TouchAccessibilityService.performTap(x, y)) hapticFeedback.click()
    }

    override fun onDestroy() {
        cameraController?.close()
        cameraController = null
        TrackingRuntime.reset()
        stopService(Intent(this, OverlayCursorService::class.java))
        isRunning = false
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return Service.START_STICKY
    }

    override fun onBind(intent: Intent): IBinder? = super.onBind(intent)
}
