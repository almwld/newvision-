package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import androidx.camera.core.ImageProxy
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.domain.model.GazeSample
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

class FaceLandmarkerAnalyzer(
    context: Context,
    private val repository: GazeRepository,
) : AutoCloseable {
    private val closed = AtomicBoolean(false)
    private val landmarker: FaceLandmarker
    private val blinkDetector = BlinkDetector()
    private val irisNormalizer = IrisNormalizer()

    init {
        landmarker = tryLoadModel(context, "assets/models/face_landmarker.task")
            ?: tryLoadModel(context, "models/face_landmarker.task")
            ?: tryLoadModel(context, "face_landmarker.task")
            ?: throw IllegalStateException("Could not load face_landmarker.task from any path")
    }

    private fun tryLoadModel(context: Context, path: String): FaceLandmarker? {
        return try {
            android.util.Log.d("FaceLandmarker", "Trying to load: $path")
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath(path)
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
                .setErrorListener { error ->
                    android.util.Log.e("FaceLandmarker", "MediaPipe error: ${error.message}", error)
                    AppLogger.e("MediaPipe error", error)
                }
                .build()
            val result = FaceLandmarker.createFromOptions(context, options)
            android.util.Log.d("FaceLandmarker", "Successfully loaded: $path")
            result
        } catch (e: Exception) {
            android.util.Log.w("FaceLandmarker", "Failed to load $path: ${e.message}")
            null
        }
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
                bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true,
            )
            if (transformed !== bitmap) bitmap.recycle()
            landmarker.detectAsync(BitmapImageBuilder(transformed).build(), timestamp)
        } catch (error: Exception) {
            android.util.Log.e("FaceLandmarker", "Frame analysis failed: ${error.message}", error)
            AppLogger.e("Frame analysis failed", error)
        } finally {
            imageProxy.close()
        }
    }

    private fun onResult(result: FaceLandmarkerResult, image: MPImage) {
        if (closed.get()) return
        val landmarks = result.faceLandmarks().firstOrNull() ?: return
        if (landmarks.size < 478) return

        val rightIris = listOf(
            landmarks[473], landmarks[474], landmarks[475], landmarks[476], landmarks[477],
        )
        val leftIris = listOf(
            landmarks[468], landmarks[469], landmarks[470], landmarks[471], landmarks[472],
        )
        val rightNormalized = irisNormalizer.normalize(
            rightIris, landmarks[33] to landmarks[133],
        )
        val leftNormalized = irisNormalizer.normalize(
            leftIris, landmarks[362] to landmarks[263],
        )
        if (rightNormalized == null || leftNormalized == null) return

        val rightEye = eyeContour(landmarks, intArrayOf(33, 160, 158, 133, 153, 144))
        val leftEye = eyeContour(landmarks, intArrayOf(362, 385, 387, 263, 373, 380))
        val blinking = blinkDetector.update(leftEye, rightEye)

        val rawX = ((rightNormalized.first + leftNormalized.first) * 0.5f).coerceIn(0f, 1f)
        val rawY = ((rightNormalized.second + leftNormalized.second) * 0.5f).coerceIn(0f, 1f)
        val faceWidth = (landmarks.maxOf { it.x() } - landmarks.minOf { it.x() }).coerceAtLeast(0f)
        val faceHeight = (landmarks.maxOf { it.y() } - landmarks.minOf { it.y() }).coerceAtLeast(0f)
        val diagonal = hypot(faceWidth.toDouble(), faceHeight.toDouble()).toFloat()
        val confidence = min(1f, diagonal * 1.5f).coerceIn(0.1f, 1f)
        val pupilDiameter = (irisDiameter(leftIris) + irisDiameter(rightIris)) * 0.5f

        repository.publish(
            GazeSample(
                rawX = rawX,
                rawY = rawY,
                leftIrisX = leftNormalized.first,
                leftIrisY = leftNormalized.second,
                rightIrisX = rightNormalized.first,
                rightIrisY = rightNormalized.second,
                confidence = confidence,
                pupilDiameter = pupilDiameter,
                eyeOpen = !blinking,
                timestampNs = result.timestampMs() * 1_000_000L,
            ),
        )
    }

    private fun irisDiameter(iris: List<NormalizedLandmark>): Float {
        if (iris.size < 5) return 0f
        val center = iris.first()
        return iris.drop(1).map {
            hypot(
                (it.x() - center.x()).toDouble(),
                (it.y() - center.y()).toDouble(),
            ).toFloat()
        }.average().toFloat() * 2f
    }

    private fun eyeContour(
        landmarks: List<NormalizedLandmark>,
        indices: IntArray,
    ): List<NormalizedLandmark> = indices.map { landmarks[it] }

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            blinkDetector.reset()
            landmarker.close()
        }
    }
}
