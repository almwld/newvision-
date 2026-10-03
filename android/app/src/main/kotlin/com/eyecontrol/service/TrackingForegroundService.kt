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
import com.eyecontrol.MainActivity
import com.eyecontrol.R
import com.eyecontrol.data.camera.CameraController
import com.eyecontrol.data.camera.TrackingRuntime

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

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        TrackingRuntime.initialize(this)
        createChannel()
        startAsForeground()
        cameraController = CameraController(this, this, TrackingRuntime.repository)
        cameraController?.start()
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

    override fun onBind(intent: Intent): IBinder = super.onBind(intent)
}
