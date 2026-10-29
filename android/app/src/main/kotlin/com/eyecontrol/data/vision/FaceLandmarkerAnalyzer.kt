package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import androidx.camera.core.ImageProxy
import com.eyecontrol.core.constants.NativeConstants
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
import java.nio.ByteBuffer
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.min

class FaceLandmarkerAnalyzer(
    context: Context,
    private val repository: GazeRepository,
) : AutoCloseable {
    private val closed = AtomicBoolean(false)
    private val landmarker: FaceLandmarker
    private val blinkDetector = BlinkDetector()
    private val l2cs = L2csInferenceEngine(context)
    private val pendingFrames = ConcurrentHashMap<Long, Bitmap>()

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
            val bitmap = rgbaBitmap(imageProxy, plane.buffer, plane.rowStride, plane.pixelStride)
            val matrix = Matrix().apply {
                postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
                if (frontCamera) postScale(-1f, 1f, 0f, 0f)
            }
            val transformed = Bitmap.createBitmap(
                bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true,
            )
            if (transformed !== bitmap) bitmap.recycle()
            pendingFrames[timestamp] = transformed
            while (pendingFrames.size > 3) {
                pendingFrames.entries.minByOrNull { it.key }?.let { pendingFrames.remove(it.key)?.recycle() }
            }
            landmarker.detectAsync(BitmapImageBuilder(transformed).build(), timestamp)
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

        val rightIris = listOf(
            landmarks[473], landmarks[474], landmarks[475], landmarks[476], landmarks[477],
        )
        val leftIris = listOf(
            landmarks[468], landmarks[469], landmarks[470], landmarks[471], landmarks[472],
        )
        val rightEye = eyeContour(landmarks, intArrayOf(33, 160, 158, 133, 153, 144))
        val leftEye = eyeContour(landmarks, intArrayOf(362, 385, 387, 263, 373, 380))
        val blinking = blinkDetector.update(leftEye, rightEye)

        val rightRatio = eyeRatio(rightIris, rightEye, image.width, image.height) ?: return
        val leftRatio = eyeRatio(leftIris, leftEye, image.width, image.height) ?: return
        // Use the same eye-contour ratios as Mudabbir's GazeFusion pipeline.
        // The horizontal inversion compensates for front-camera mirroring.
        val rawX = (1f - (rightRatio.first + leftRatio.first) * 0.5f).coerceIn(0f, 1f)
        val rawY = ((rightRatio.second + leftRatio.second) * 0.5f).coerceIn(0f, 1f)
        // Score confidence from eye openness and left/right consistency, not
        // merely the size of the face.
        val leftOpenness = eyeOpenness(leftEye, image.width, image.height) ?: 0f
        val rightOpenness = eyeOpenness(rightEye, image.width, image.height) ?: 0f
        val opennessQuality = (min(leftOpenness, rightOpenness) / 0.22f).coerceIn(0f, 1f)
        val symmetryError = abs(leftRatio.first - rightRatio.first) +
            abs(leftRatio.second - rightRatio.second)
        val symmetryQuality = (1f - symmetryError / 1.1f).coerceIn(0f, 1f)
        val confidence = (opennessQuality * symmetryQuality).coerceIn(0f, 1f)
        val pupilDiameter = (irisDiameter(leftIris) + irisDiameter(rightIris)) * 0.5f
        val minX = landmarks.minOf { it.x() }.coerceIn(0f, 1f) * image.width.toFloat()
        val minY = landmarks.minOf { it.y() }.coerceIn(0f, 1f) * image.height.toFloat()
        val maxX = landmarks.maxOf { it.x() }.coerceIn(0f, 1f) * image.width.toFloat()
        val maxY = landmarks.maxOf { it.y() }.coerceIn(0f, 1f) * image.height.toFloat()

        val frameBitmap = pendingFrames.remove(result.timestampMs())
        val l2csResult = frameBitmap?.let { frame ->
            try {
                l2cs.infer(frame, minX, minY, maxX, maxY)
            } catch (error: Exception) {
                AppLogger.e("L2CS inference failed", error)
                null
            } finally {
                frame.recycle()
            }
        }

        repository.publish(
            GazeSample(
                rawX = rawX,
                rawY = rawY,
                leftIrisX = leftRatio.first,
                leftIrisY = leftRatio.second,
                rightIrisX = rightRatio.first,
                rightIrisY = rightRatio.second,
                confidence = confidence,
                pupilDiameter = pupilDiameter,
                eyeOpen = !blinking,
                timestampNs = result.timestampMs() * 1_000_000L,
                yawDegrees = l2csResult?.yawDegrees,
                pitchDegrees = l2csResult?.pitchDegrees,
                gazeConfidence = l2csResult?.confidence,
            ),
        )
    }

    private fun rgbaBitmap(
        imageProxy: ImageProxy,
        source: ByteBuffer,
        rowStride: Int,
        pixelStride: Int,
    ): Bitmap {
        val width = imageProxy.width
        val height = imageProxy.height
        require(pixelStride == 4) { "Unsupported RGBA pixel stride: $pixelStride" }

        val packed = ByteBuffer.allocateDirect(width * height * 4)
        val row = ByteArray(width * 4)
        val duplicate = source.duplicate()

        for (y in 0 until height) {
            duplicate.position(y * rowStride)
            duplicate.get(row, 0, width * 4)
            packed.put(row)
        }
        packed.rewind()

        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also {
            it.copyPixelsFromBuffer(packed)
        }
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

    private fun eyeRatio(
        iris: List<NormalizedLandmark>,
        contour: List<NormalizedLandmark>,
        imageWidth: Int,
        imageHeight: Int,
    ): Pair<Float, Float>? {
        if (iris.isEmpty() || contour.size < 6 || imageWidth <= 0 || imageHeight <= 0) return null
        val minX = contour.minOf { it.x() } * imageWidth
        val maxX = contour.maxOf { it.x() } * imageWidth
        val minY = contour.minOf { it.y() } * imageHeight
        val maxY = contour.maxOf { it.y() } * imageHeight
        val width = maxX - minX
        val height = maxY - minY
        if (!width.isFinite() || !height.isFinite() || width < 2f || height < 1f) return null
        val irisCenter = iris.first()
        val irisX = irisCenter.x() * imageWidth
        val irisY = irisCenter.y() * imageHeight
        return Pair(
            ((irisX - minX) / width).coerceIn(0f, 1f),
            ((irisY - minY) / height).coerceIn(0f, 1f),
        )
    }

    private fun eyeOpenness(
        contour: List<NormalizedLandmark>,
        imageWidth: Int,
        imageHeight: Int,
    ): Float? {
        if (contour.size < 6 || imageWidth <= 0 || imageHeight <= 0) return null
        val minX = contour.minOf { it.x() } * imageWidth
        val maxX = contour.maxOf { it.x() } * imageWidth
        val minY = contour.minOf { it.y() } * imageHeight
        val maxY = contour.maxOf { it.y() } * imageHeight
        val width = maxX - minX
        val height = maxY - minY
        if (!width.isFinite() || !height.isFinite() || width < 2f || height < 1f) return null
        return (height / width).takeIf { it.isFinite() }
    }

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            blinkDetector.reset()
            landmarker.close()
            pendingFrames.values.forEach { it.recycle() }
            pendingFrames.clear()
            l2cs.close()
        }
    }
}
