package com.eyecontrol.service

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import com.eyecontrol.domain.model.ScreenPoint
import java.util.concurrent.atomic.AtomicReference

class OverlayCursorService : Service() {
    private lateinit var windowManager: WindowManager
    private var cursor: View? = null
    private lateinit var params: WindowManager.LayoutParams

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WindowManager::class.java)
        cursor = View(this).apply { setBackgroundColor(0xCC0A8F83.toInt()) }
        params = WindowManager.LayoutParams(
            28,
            28,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 0
        }
        windowManager.addView(cursor, params)
        instance.set(this)
    }

    fun update(point: ScreenPoint) {
        if (point.isBlinking) return
        moveTo(point.xPx.toInt() - 14, point.yPx.toInt() - 14)
    }

    private fun moveTo(x: Int, y: Int) {
        val view = cursor ?: return
        params.x = x.coerceAtLeast(0)
        params.y = y.coerceAtLeast(0)
        windowManager.updateViewLayout(view, params)
    }

    override fun onDestroy() {
        instance.compareAndSet(this, null)
        cursor?.let(windowManager::removeView)
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
