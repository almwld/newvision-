package com.eyecontrol.data.camera

import android.content.Context
import com.eyecontrol.data.repository.NativeGazeRepository
import com.eyecontrol.data.repository.NativeCalibrationRepository
import com.eyecontrol.data.repository.NativeGazeRepositoryFactory
import com.eyecontrol.core.platform.ScreenGeometry

/**
 * Process-local tracking runtime shared by the Activity and the foreground service.
 * The foreground service keeps the process alive while the Activity is gone.
 */
object TrackingRuntime {
    @Volatile private var initialized = false
    private lateinit var repositoryValue: NativeGazeRepository
    private lateinit var calibrationRepositoryValue: NativeCalibrationRepository

    @Synchronized
    fun initialize(context: Context) {
        if (initialized) return
        val app = context.applicationContext
        val factory = NativeGazeRepositoryFactory(app)
        calibrationRepositoryValue = factory.calibrationRepository()
        repositoryValue = factory.create(
            screenWidth = ScreenGeometry.realMetrics(app).widthPixels,
            screenHeight = ScreenGeometry.realMetrics(app).heightPixels,
        )
        initialized = true
    }

    val calibrationRepository: NativeCalibrationRepository
        get() {
            check(initialized) { "TrackingRuntime has not been initialized" }
            return calibrationRepositoryValue
        }

    val repository: NativeGazeRepository
        get() {
            check(initialized) { "TrackingRuntime has not been initialized" }
            return repositoryValue
        }

    fun reset() {
        if (initialized) repositoryValue.reset()
    }
}
