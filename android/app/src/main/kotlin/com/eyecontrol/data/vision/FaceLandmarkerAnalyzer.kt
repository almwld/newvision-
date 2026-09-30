package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import androidx.camera.core.ImageProxy
import com.eyecontrol.core.constants.NativeConstants
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.domain.model.GazeFrame
import com.eyecontrol.domain.repository.GazeRepository
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarker
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarkerResult
import java.util.concurrent.atomic.AtomicBoolean

class FaceLandmarkerAnalyzer(
    context: Context,
    private val repository: GazeRepository,
) : AutoCloseable {

    private val closed = AtomicBoolean(false)
    private val landmarker: FaceLandmarker

    init {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(NativeConstants.MODEL_ASSET)
            .build()
        val options = FaceLandmarker.FaceLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setMinFaceDetectionConfidence(0.5f)
            .setMinFacePresenceConfidence(0.5f)
            .setMinTrackingConfidence(0.5f)
            .setNumFaces(1)
            .setOutputFaceBlendshapes(true)
            .setRunningMode(RunningMode.LIVE_STREAM)
            .setResultListener(this::onResult)
            .setErrorListener { error -> AppLogger.e("MediaPipe error", error) }
            .build()
        landmarker = FaceLandmarker.createFromOptions(context, options)
    }

    fun analyze(imageProxy: ImageProxy, frontCamera: Boolean) {
        if (closed.get()) {
            imageProxy.close()
            return
        }
        val timestamp = SystemClock.uptimeMillis()
        try {
            val bitmap = Bitmap.createBitmap(
                imageProxy.width,
                imageProxy.height,
                Bitmap.Config.ARGB_8888,
            )
            imageProxy.use { bitmap.copyPixelsFromBuffer(it.planes[0].buffer) }
            val matrix = Matrix().apply {
                postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
                if (frontCamera) {
                    postScale(
                        -1f,
                        1f,
                        imageProxy.width.toFloat(),
                        imageProxy.height.toFloat(),
                    )
                }
            }
            val rotated = Bitmap.createBitmap(
                bitmap,
                0,
                0,
                bitmap.width,
                bitmap.height,
                matrix,
                true,
            )
            landmarker.detectAsync(BitmapImageBuilder(rotated).build(), timestamp)
        } catch (error: RuntimeException) {
            AppLogger.e("Frame analysis failed", error)
        } finally {
            if (!imageProxy.isClosed) imageProxy.close()
        }
    }

    private fun onResult(result: FaceLandmarkerResult, image: com.google.mediapipe.framework.image.MPImage) {
        val landmarks = result.faceLandmarks().firstOrNull() ?: return
        val leftIris = landmarks.subList(468.coerceAtMost(landmarks.size), landmarks.size)
        if (leftIris.isEmpty()) return
        val center = leftIris.reduce { acc, landmark ->
            acc.copy(
                x = (acc.x() + landmark.x()) / 2f,
                y = (acc.y() + landmark.y()) / 2f,
            )
        }
        repository.publish(
            GazeFrame(
                x = center.x(),
                y = center.y(),
                confidence = 1f,
                timestampMs = result.timestampMs(),
                blinking = false,
            ),
        )
    }

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            landmarker.close()
        }
    }
}
