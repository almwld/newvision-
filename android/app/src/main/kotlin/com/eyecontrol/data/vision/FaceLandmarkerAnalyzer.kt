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
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarker
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarkerResult
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.hypot
import kotlin.math.min

/**
 * Converts CameraX RGBA frames to MediaPipe and extracts both iris centers and blink state.
 *
 * CameraX is configured to emit RGBA_8888, so the luminance plane is never misread as ARGB.
 */
class FaceLandmarkerAnalyzer(
    context: Context,
    private val repository: GazeRepository,
) : AutoCloseable {

    private val closed = AtomicBoolean(false)
    private val landmarker: FaceLandmarker
    private val blinkDetector = BlinkDetector()

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
            val plane = imageProxy.planes.firstOrNull()
                ?: throw IllegalStateException("Camera returned no RGBA plane.")
            val buffer = plane.buffer
            buffer.rewind()

            val bitmap = Bitmap.createBitmap(
                imageProxy.width,
                imageProxy.height,
                Bitmap.Config.ARGB_8888,
            )
            bitmap.copyPixelsFromBuffer(buffer)

            val matrix = Matrix().apply {
                postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
                if (frontCamera) postScale(-1f, 1f, 0f, 0f)
            }
            val transformed = Bitmap.createBitmap(
                bitmap,
                0,
                0,
                bitmap.width,
                bitmap.height,
                matrix,
                true,
            )
            if (transformed !== bitmap) bitmap.recycle()

            landmarker.detectAsync(
                BitmapImageBuilder(transformed).build(),
                timestamp,
            )
        } catch (error: Exception) {
            AppLogger.e("Frame analysis failed", error)
        } finally {
            imageProxy.close()
        }
    }

    private fun onResult(result: FaceLandmarkerResult, image: MPImage) {
        if (closed.get()) return
        val landmarks = result.faceLandmarks().firstOrNull() ?: return
        if (landmarks.size < 478) return

        val rightIris = landmarks.subList(469, 473)
        val leftIris = landmarks.subList(474, 478)
        val rightCenter = center(rightIris)
        val leftCenter = center(leftIris)

        val gazeX = ((rightCenter.first + leftCenter.first) * 0.5f).coerceIn(0f, 1f)
        val gazeY = ((rightCenter.second + leftCenter.second) * 0.5f).coerceIn(0f, 1f)

        val rightEye = eyeContour(landmarks, intArrayOf(33, 160, 158, 133, 153, 144))
        val leftEye = eyeContour(landmarks, intArrayOf(362, 385, 387, 263, 373, 380))
        val blinking = blinkDetector.update(leftEye, rightEye)

        val faceWidth = (landmarks.maxOf { it.x() } - landmarks.minOf { it.x() }).coerceAtLeast(0f)
        val faceHeight = (landmarks.maxOf { it.y() } - landmarks.minOf { it.y() }).coerceAtLeast(0f)
        val diagonal = hypot(faceWidth.toDouble(), faceHeight.toDouble()).toFloat()
        val confidence = min(1f, diagonal * 1.5f).coerceIn(0.1f, 1f)

        repository.publish(
            GazeFrame(
                x = gazeX,
                y = gazeY,
                confidence = confidence,
                timestampMs = result.timestampMs(),
                blinking = blinking,
            ),
        )
    }

    private fun center(landmarks: List<NormalizedLandmark>): Pair<Float, Float> =
        Pair(
            landmarks.sumOf { it.x().toDouble() }.toFloat() / landmarks.size,
            landmarks.sumOf { it.y().toDouble() }.toFloat() / landmarks.size,
        )

    private fun eyeContour(
        landmarks: List<NormalizedLandmark>,
        indices: IntArray,
    ): List<NormalizedLandmark> = indices.map { landmarks[it] }

    override fun close() {
        if (closed.compareAndSet(false, true)) landmarker.close()
    }
}
