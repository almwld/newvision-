package com.eyecontrol.service

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager

class OverlayCursorService : Service() {
    private lateinit var windowManager: WindowManager
    private var cursor: View? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WindowManager::class.java)
        cursor = View(this).apply { setBackgroundColor(0x99FFFFFF.toInt()) }
        val params = WindowManager.LayoutParams(
            28, 28,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT,
        ).apply { gravity = Gravity.TOP or Gravity.START }
        windowManager.addView(cursor, params)
    }

    override fun onDestroy() {
        cursor?.let(windowManager::removeView)
        cursor = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
