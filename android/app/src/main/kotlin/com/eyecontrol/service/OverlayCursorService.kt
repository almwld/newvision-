package com.eyecontrol.service

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import com.eyecontrol.domain.model.ScreenPoint
import java.util.concurrent.atomic.AtomicReference

/** The gaze cursor is a non-touchable system overlay, so it follows gaze on top
 * of other apps without intercepting their gestures. */
class OverlayCursorService : Service() {
    private lateinit var windowManager: WindowManager
    private var cursor: View? = null
    private lateinit var params: WindowManager.LayoutParams
    private var cursorSize = 34

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WindowManager::class.java)
        val density = resources.displayMetrics.density
        cursorSize = (34 * density).toInt()
        val ring = FrameLayout(this).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0x330A8F83)
                setStroke((3 * density).toInt().coerceAtLeast(2), 0xFF0A8F83.toInt())
            }
            elevation = 8f * density
            addView(View(this@OverlayCursorService).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(0xFF0A8F83.toInt())
                }
            }, FrameLayout.LayoutParams((8 * density).toInt(), (8 * density).toInt(), Gravity.CENTER))
        }
        params = WindowManager.LayoutParams(
            cursorSize,
            cursorSize,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 0
        }
        try {
            windowManager.addView(ring, params)
            cursor = ring
            instance.set(this)
        } catch (error: Exception) {
            cursor = null
            stopSelf()
        }
    }

    fun update(point: ScreenPoint) {
        if (point.isBlinking || !point.xPx.isFinite() || !point.yPx.isFinite()) return
        moveTo(point.xPx.toInt() - cursorSize / 2, point.yPx.toInt() - cursorSize / 2)
    }

    private fun moveTo(x: Int, y: Int) {
        val view = cursor ?: return
        val metrics = resources.displayMetrics
        params.x = x.coerceIn(0, (metrics.widthPixels - cursorSize).coerceAtLeast(0))
        params.y = y.coerceIn(0, (metrics.heightPixels - cursorSize).coerceAtLeast(0))
        runCatching { windowManager.updateViewLayout(view, params) }
    }

    override fun onDestroy() {
        instance.compareAndSet(this, null)
        cursor?.let { view -> runCatching { windowManager.removeView(view) } }
        cursor = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        private val instance = AtomicReference<OverlayCursorService?>()
        fun update(point: ScreenPoint) {
            instance.get()?.update(point)
        }
    }
}