package com.eyecontrol.data.camera

import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.data.vision.FaceLandmarkerAnalyzer
import com.eyecontrol.domain.repository.GazeRepository
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Owns the CameraX analysis pipeline and deliberately keeps only the newest frame.
 */
class CameraController(
    private val context: android.content.Context,
    private val lifecycleOwner: LifecycleOwner,
    private val repository: GazeRepository,
) : AutoCloseable {

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private var provider: ProcessCameraProvider? = null
    private var analyzer: FaceLandmarkerAnalyzer? = null

    fun start() {
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener(
            {
                try {
                    val cameraProvider = future.get()
                    provider = cameraProvider
                    analyzer?.close()
                    analyzer = FaceLandmarkerAnalyzer(context, repository)

                    val analysis = ImageAnalysis.Builder()
                        .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .setImageQueueDepth(1)
                        .build()

                    val faceAnalyzer = analyzer ?: return@addListener
                    analysis.setAnalyzer(executor) { image ->
                        faceAnalyzer.analyze(image, frontCamera = true)
                    }

                    cameraProvider.unbindAll()
                    cameraProvider.bindToLifecycle(
                        lifecycleOwner,
                        CameraSelector.DEFAULT_FRONT_CAMERA,
                        analysis,
                    )
                    AppLogger.i("Camera analysis started at 30 FPS target")
                } catch (error: Exception) {
                    AppLogger.e("Unable to start camera analysis", error)
                }
            },
            ContextCompat.getMainExecutor(context),
        )
    }

    fun stop() {
        provider?.unbindAll()
        analyzer?.close()
        analyzer = null
        AppLogger.i("Camera analysis stopped")
    }

    override fun close() {
        stop()
        executor.shutdown()
    }
}
