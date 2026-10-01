package com.eyecontrol.domain.repository

import com.eyecontrol.domain.model.CalibrationData

interface CalibrationRepository {
    suspend fun save(model: CalibrationData)
    suspend fun load(): CalibrationData?
    suspend fun clear()
}
