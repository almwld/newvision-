package com.eyecontrol.domain.repository

import com.eyecontrol.domain.model.GazeFrame
import kotlinx.coroutines.flow.StateFlow

interface GazeRepository {
    val latest: StateFlow<GazeFrame?>
    fun publish(frame: GazeFrame)
    fun clear()
}
