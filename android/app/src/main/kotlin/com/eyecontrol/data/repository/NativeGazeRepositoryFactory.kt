package com.eyecontrol.data.repository

import android.content.Context
import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.calibration.CalibrationStore

class NativeGazeRepositoryFactory(context: Context) {
    private val calibrationManager = CalibrationManager(
        CalibrationStore(context.applicationContext),
    )

    fun create(screenWidth: Int, screenHeight: Int): NativeGazeRepository =
        NativeGazeRepository(
            calibrationManager = calibrationManager,
            screenWidth = screenWidth,
            screenHeight = screenHeight,
        )

    fun calibrationRepository(): NativeCalibrationRepository =
        NativeCalibrationRepository(calibrationManager)
}
