package com.eyecontrol.data.camera

import android.content.Context
import com.eyecontrol.data.repository.NativeGazeRepository
import com.eyecontrol.data.repository.NativeGazeRepositoryFactory

/**
 * Process-local tracking runtime shared by the Activity and the foreground service.
 * The foreground service keeps the process alive while the Activity is gone.
 */
object TrackingRuntime {
    @Volatile private var initialized = false
    private lateinit var repositoryValue: NativeGazeRepository

    @Synchronized
    fun initialize(context: Context) {
        if (initialized) return
        val app = context.applicationContext
        val factory = NativeGazeRepositoryFactory(app)
        repositoryValue = factory.create(
            screenWidth = app.resources.displayMetrics.widthPixels,
            screenHeight = app.resources.displayMetrics.heightPixels,
        )
        initialized = true
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
