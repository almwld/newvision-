package com.eyecontrol.data.camera

import android.os.Handler
import android.os.Looper
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.core.UseCase
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.eyecontrol.core.logging.AppLogger
import com.eyecontrol.core.performance.CameraRecovery
import com.eyecontrol.data.vision.FaceLandmarkerAnalyzer
import com.eyecontrol.domain.repository.GazeRepository
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Owns the CameraX analysis pipeline and optionally attaches the Flutter preview surface.
 * The foreground service remains the sole camera owner, so image analysis continues when
 * the Activity and its preview surface are removed.
 */
class CameraController(
    private val context: android.content.Context,
    private val lifecycleOwner: LifecycleOwner,
    private val repository: GazeRepository,
) : AutoCloseable {

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private var provider: ProcessCameraProvider? = null
    private var analyzer: FaceLandmarkerAnalyzer? = null
    private var analysisUseCase: ImageAnalysis? = null
    private var previewUseCase: Preview? = null
    private var previewListener: AutoCloseable? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val recovery = CameraRecovery()
    @Volatile private var closed = false

    fun start() {
        closed = false
        mainHandler.removeCallbacksAndMessages(null)
        if (previewListener == null) {
            previewListener = TrackingPreviewRegistry.addListener {
                mainHandler.post { rebindCurrentUseCases() }
            }
        }
        startAttempt(0)
    }

    private fun startAttempt(attempt: Int) {
        if (closed) return
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
                    analysisUseCase = analysis
                    bindUseCases(cameraProvider)
                    AppLogger.i("Camera analysis started at 30 FPS target")
                } catch (error: Exception) {
                    AppLogger.e("Unable to start camera analysis (attempt " + (attempt + 1) + ")", error)
                    if (!closed && attempt < 2) {
                        val delay = recovery.delayForAttempt(attempt)
                        mainHandler.postDelayed({ startAttempt(attempt + 1) }, delay)
                    } else if (!closed) {
                        AppLogger.e("Camera recovery exhausted after 3 attempts", error)
                    }
                }
            },
            ContextCompat.getMainExecutor(context),
        )
    }

    private fun rebindCurrentUseCases() {
        val cameraProvider = provider ?: return
        if (closed || analysisUseCase == null) return
        try {
            bindUseCases(cameraProvider)
        } catch (error: Exception) {
            AppLogger.e("Unable to attach/detach camera preview", error)
        }
    }

    private fun bindUseCases(cameraProvider: ProcessCameraProvider) {
        if (closed) return
        val analysis = analysisUseCase ?: return
        val view = TrackingPreviewRegistry.currentView()
        val preview = view?.let { previewView ->
            Preview.Builder().build().also { useCase ->
                useCase.setSurfaceProvider(previewView.surfaceProvider)
            }
        }
        val useCases = mutableListOf<UseCase>()
        if (preview != null) useCases.add(preview)
        useCases.add(analysis)

        cameraProvider.unbindAll()
        cameraProvider.bindToLifecycle(
            lifecycleOwner,
            CameraSelector.DEFAULT_FRONT_CAMERA,
            *useCases.toTypedArray(),
        )
        previewUseCase = preview
    }

    fun stop() {
        mainHandler.removeCallbacksAndMessages(null)
        provider?.unbindAll()
        analysisUseCase = null
        previewUseCase = null
        analyzer?.close()
        analyzer = null
        AppLogger.i("Camera analysis stopped")
    }

    override fun close() {
        closed = true
        previewListener?.close()
        previewListener = null
        stop()
        executor.shutdown()
    }
}
