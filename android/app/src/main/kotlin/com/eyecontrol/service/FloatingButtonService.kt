package com.eyecontrol.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.eyecontrol.MainActivity
import com.eyecontrol.R

/** Persistent, movable eye-control button. It deliberately lives in a system overlay,
 * so the same controls remain available after the user leaves NewVision. */
class FloatingButtonService : Service() {
    companion object {
        private const val TAG = "FloatingBtn"
        private const val CHANNEL_ID = "newvision_floating"
        private const val NOTIF_ID = 1001
        const val ACTION_TOGGLE = "com.eyecontrol.TOGGLE_TRACKING"
        const val ACTION_EMERGENCY = "com.eyecontrol.EMERGENCY"
        const val ACTION_TAP_CENTER = "com.eyecontrol.TAP_CENTER"
        const val ACTION_SCROLL_UP = "com.eyecontrol.SCROLL_UP"
        const val ACTION_SCROLL_DOWN = "com.eyecontrol.SCROLL_DOWN"
        const val ACTION_SCROLL_LEFT = "com.eyecontrol.SCROLL_LEFT"
        const val ACTION_SCROLL_RIGHT = "com.eyecontrol.SCROLL_RIGHT"

        @Volatile var isRunning = false
            private set
    }

    private lateinit var windowManager: WindowManager
    private var floatingView: View? = null
    private var buttonView: ImageView? = null
    private var panelView: LinearLayout? = null
    private var params: WindowManager.LayoutParams? = null
    private var density = 1f
    private var buttonSize = 60

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createChannel()
        startForegroundCompat()
        if (!Settings.canDrawOverlays(this)) {
            Log.w(TAG, "Overlay permission missing")
            Toast.makeText(this, "اسمح لـ NewVision بالظهور فوق التطبيقات أولاً", Toast.LENGTH_LONG).show()
            stopSelf()
            return
        }
        addFloatingButton()
    }

    private fun startForegroundCompat() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else startForeground(NOTIF_ID, notification)
    }

    private fun addFloatingButton() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        density = resources.displayMetrics.density
        buttonSize = (58 * density).toInt()
        val panelWidth = (232 * density).toInt()
        val container = FrameLayout(this)

        val button = ImageView(this).apply {
            setImageResource(R.drawable.ic_eye)
            setBackgroundResource(R.drawable.floating_button_bg)
            setPadding((14 * density).toInt(), (14 * density).toInt(), (14 * density).toInt(), (14 * density).toInt())
            contentDescription = "قائمة إجراءات NewVision"
            isClickable = true
            isFocusable = true
            elevation = 12f * density
        }
        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding((9 * density).toInt(), (9 * density).toInt(), (9 * density).toInt(), (9 * density).toInt())
            background = GradientDrawable().apply {
                setColor(0xF51E293B.toInt())
                cornerRadius = 20f * density
                setStroke((1.2f * density).toInt(), 0xFF0A8F83.toInt())
            }
            visibility = View.GONE
            elevation = 14f * density
        }

        fun actionButton(label: String, action: String, danger: Boolean = false): TextView =
            TextView(this).apply {
                text = label
                textSize = 14f
                setTextColor(if (danger) 0xFFFFD8D8.toInt() else 0xFFFFFFFF.toInt())
                gravity = Gravity.CENTER
                minHeight = (42 * density).toInt()
                setPadding((12 * density).toInt(), (9 * density).toInt(), (12 * density).toInt(), (9 * density).toInt())
                isClickable = true
                isFocusable = true
                background = GradientDrawable().apply {
                    setColor(if (danger) 0xFF6B2630.toInt() else 0xFF334155.toInt())
                    cornerRadius = 13f * density
                    setStroke((1 * density).toInt(), if (danger) 0x66FF8080 else 0x440A8F83)
                }
                setOnClickListener {
                    sendBroadcast(Intent(action).setPackage(packageName))
                    panel.visibility = View.GONE
                }
                layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                    bottomMargin = (6 * density).toInt()
                }
            }

        panel.addView(TextView(this).apply {
            text = "التحكم بالنظر"
            textSize = 14f
            setTextColor(0xFF7DE0D4.toInt())
            gravity = Gravity.CENTER
            setPadding(4, (3 * density).toInt(), 4, (9 * density).toInt())
        })
        val actions = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        actions.addView(actionButton("تشغيل / إيقاف التتبع", ACTION_TOGGLE))
        actions.addView(actionButton("نقرة في المنتصف", ACTION_TAP_CENTER))
        actions.addView(actionButton("تمرير لأعلى", ACTION_SCROLL_UP))
        actions.addView(actionButton("تمرير لأسفل", ACTION_SCROLL_DOWN))
        actions.addView(actionButton("تمرير لليمين", ACTION_SCROLL_RIGHT))
        actions.addView(actionButton("تمرير لليسار", ACTION_SCROLL_LEFT))
        actions.addView(actionButton("إيقاف طارئ", ACTION_EMERGENCY, danger = true))
        val metrics = resources.displayMetrics
        val availableDp = metrics.heightPixels / density
        val maxActionsHeight = (availableDp - 58f - 80f).coerceIn(160f, 350f)
        panel.addView(ScrollView(this).apply {
            isFillViewport = true
            isVerticalScrollBarEnabled = false
            addView(actions)
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (maxActionsHeight * density).toInt()))

        container.addView(panel, FrameLayout.LayoutParams(panelWidth, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.TOP or Gravity.LEFT).apply {
            topMargin = buttonSize + (8 * density).toInt()
        })
        container.addView(button, FrameLayout.LayoutParams(buttonSize, buttonSize, Gravity.TOP or Gravity.LEFT))

        val windowWidth = panelWidth
        val screenHeight = resources.displayMetrics.heightPixels
        val windowHeight = (buttonSize + (66 * density).toInt() + (maxOf(160f, (screenHeight / density - 58f - 80f).coerceAtMost(350f)) * density).toInt())
            .coerceAtMost((screenHeight - (8 * density).toInt()).coerceAtLeast(buttonSize))
        params = WindowManager.LayoutParams(
            windowWidth, windowHeight,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.LEFT
            x = (16 * density).toInt()
            y = ((resources.displayMetrics.heightPixels - windowHeight) * 0.30f).toInt().coerceAtLeast(0)
        }

        button.setOnTouchListener(FloatingTouchListener(button, panel, container))
        windowManager.addView(container, params)
        floatingView = container
        buttonView = button
        panelView = panel
    }

    private inner class FloatingTouchListener(
        private val button: ImageView,
        private val panel: LinearLayout,
        private val container: View,
    ) : View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var touchX = 0f
        private var touchY = 0f
        private var dragging = false
        private var downTime = 0L

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val p = params ?: return false
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = p.x
                    initialY = p.y
                    touchX = event.rawX
                    touchY = event.rawY
                    dragging = false
                    downTime = System.currentTimeMillis()
                    return true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - touchX
                    val dy = event.rawY - touchY
                    if (kotlin.math.abs(dx) > 9 * density || kotlin.math.abs(dy) > 9 * density) dragging = true
                    if (dragging) {
                        val metrics = resources.displayMetrics
                        p.x = (initialX + dx.toInt()).coerceIn(0, (metrics.widthPixels - p.width).coerceAtLeast(0))
                        p.y = (initialY + dy.toInt()).coerceIn(0, (metrics.heightPixels - p.height).coerceAtLeast(0))
                        runCatching { windowManager.updateViewLayout(container, p) }
                    }
                    return true
                }
                MotionEvent.ACTION_UP -> {
                    val elapsed = System.currentTimeMillis() - downTime
                    if (!dragging) {
                        if (elapsed > 850) {
                            sendBroadcast(Intent(ACTION_EMERGENCY).setPackage(packageName))
                        } else {
                            panel.visibility = if (panel.visibility == View.VISIBLE) View.GONE else View.VISIBLE
                        }
                    } else {
                        val metrics = resources.displayMetrics
                        val rightSide = p.x + p.width / 2 > metrics.widthPixels / 2
                        p.x = if (rightSide) (metrics.widthPixels - p.width).coerceAtLeast(0) else 0
                        val buttonGravity = if (rightSide) Gravity.TOP or Gravity.RIGHT else Gravity.TOP or Gravity.LEFT
                        button.layoutParams = (button.layoutParams as FrameLayout.LayoutParams).apply {
                            gravity = buttonGravity
                        }
                        (panel.layoutParams as FrameLayout.LayoutParams).apply {
                            gravity = Gravity.TOP or Gravity.LEFT
                            topMargin = buttonSize + (8 * density).toInt()
                        }
                        runCatching { windowManager.updateViewLayout(container, p) }
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
                NotificationChannel(CHANNEL_ID, "NewVision Floating Control", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "زر عائم للتحكم بتتبع العين خارج التطبيق"
                },
            )
        }
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pending = android.app.PendingIntent.getActivity(this, 0, intent,
            android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_eye)
            .setContentTitle("NewVision نشط")
            .setContentText("زر التحكم العائم متاح فوق التطبيقات")
            .setContentIntent(pending)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        isRunning = false
        floatingView?.let { view -> runCatching { windowManager.removeView(view) } }
        floatingView = null
        buttonView = null
        panelView = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = Service.START_STICKY
    override fun onBind(intent: Intent?): IBinder? = null
}