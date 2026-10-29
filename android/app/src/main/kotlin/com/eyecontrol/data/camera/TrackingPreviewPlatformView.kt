package com.eyecontrol.data.camera

import android.content.Context
import android.view.View
import androidx.camera.view.PreviewView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Native CameraX preview surface exposed to Flutter. The foreground tracking service
 * remains the single owner of the camera; this view only supplies/withdraws its surface.
 */
class TrackingPreviewPlatformView(context: Context) : PlatformView {
    private val previewView = PreviewView(context).apply {
        scaleType = PreviewView.ScaleType.FILL_CENTER
        implementationMode = PreviewView.ImplementationMode.PERFORMANCE
        contentDescription = "معاينة الكاميرا الأمامية لتتبع النظر"
    }

    init {
        TrackingRuntime.setPreviewView(previewView)
    }

    override fun getView(): View = previewView

    override fun dispose() {
        TrackingRuntime.setPreviewView(null)
    }
}

class TrackingPreviewPlatformViewFactory :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        TrackingPreviewPlatformView(context)
}

/** Small observer registry used to rebind CameraX when Flutter attaches/detaches preview. */
object TrackingPreviewRegistry {
    @Volatile
    private var current: PreviewView? = null
    private val listeners = CopyOnWriteArrayList<(PreviewView?) -> Unit>()

    fun currentView(): PreviewView? = current

    fun set(view: PreviewView?) {
        current = view
        listeners.forEach { listener -> runCatching { listener(view) } }
    }

    fun addListener(listener: (PreviewView?) -> Unit): AutoCloseable {
        listeners.add(listener)
        listener(current)
        return AutoCloseable { listeners.remove(listener) }
    }
}
