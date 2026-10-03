package com.eyecontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import com.eyecontrol.MainActivity
import com.eyecontrol.R

class FloatingButtonService : Service() {
    companion object {
        private const val TAG = "FloatingBtn"
        private const val CHANNEL_ID = "newvision_floating"
        private const val NOTIF_ID = 1001
        const val ACTION_TOGGLE = "com.eyecontrol.TOGGLE_TRACKING"
        const val ACTION_EMERGENCY = "com.eyecontrol.EMERGENCY"

        @Volatile var isRunning = false
            private set
    }

    private lateinit var windowManager: WindowManager
    private var floatingView: View? = null
    private var params: WindowManager.LayoutParams? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate")
        isRunning = true
        createChannel()
        startForegroundCompat()

        if (!Settings.canDrawOverlays(this)) {
            Log.w(TAG, "Overlay permission missing")
            stopSelf()
            return
        }
        addFloatingButton()
    }

    private fun startForegroundCompat() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private fun addFloatingButton() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val size = (60 * resources.displayMetrics.density).toInt()
        val imageView = ImageView(this).apply {
            setImageResource(R.drawable.ic_eye)
            setBackgroundResource(R.drawable.floating_button_bg)
            setPadding(15, 15, 15, 15)
            contentDescription = "تحكم NewVision"
        }

        params = WindowManager.LayoutParams(
            size,
            size,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 24
            y = 300
        }

        imageView.setOnTouchListener(FloatingTouchListener())
        windowManager.addView(imageView, params)
        floatingView = imageView
        Log.d(TAG, "Floating button added")
    }

    private inner class FloatingTouchListener : View.OnTouchListener {
        private var initX = 0
        private var initY = 0
        private var touchX = 0f
        private var touchY = 0f
        private var dragging = false
        private var downTime = 0L

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val p = params ?: return false
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initX = p.x
                    initY = p.y
                    touchX = event.rawX
                    touchY = event.rawY
                    dragging = false
                    downTime = System.currentTimeMillis()
                    return true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - touchX
                    val dy = event.rawY - touchY
                    if (kotlin.math.abs(dx) > 10 || kotlin.math.abs(dy) > 10) dragging = true
                    if (dragging) {
                        p.x = initX + dx.toInt()
                        p.y = initY + dy.toInt()
                        windowManager.updateViewLayout(v, p)
                    }
                    return true
                }
                MotionEvent.ACTION_UP -> {
                    val elapsed = System.currentTimeMillis() - downTime
                    if (!dragging) {
                        if (elapsed > 800) {
                            Log.d(TAG, "Emergency stop")
                            sendBroadcast(Intent(ACTION_EMERGENCY).setPackage(packageName))
                        } else {
                            Log.d(TAG, "Toggle tracking")
                            sendBroadcast(Intent(ACTION_TOGGLE).setPackage(packageName))
                        }
                    } else {
                        val screenWidth = resources.displayMetrics.widthPixels
                        p.x = if (p.x > screenWidth / 2) screenWidth - v.width else 0
                        windowManager.updateViewLayout(v, p)
                    }
                    return true
                }
            }
            return false
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "NewVision Floating Control",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = "زر عائم للتحكم بتتبع العين"
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
            0,
            intent,
            android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_eye)
            .setContentTitle("NewVision نشط")
            .setContentText("الزر العائم متاح فوق التطبيقات")
            .setContentIntent(pending)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        isRunning = false
        floatingView?.let {
            runCatching { windowManager.removeView(it) }
        }
        floatingView = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = Service.START_STICKY

    override fun onBind(intent: Intent?): IBinder? = null

}
