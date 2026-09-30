package com.eyecontrol.domain.repository

import com.eyecontrol.domain.model.GazeSample
import com.eyecontrol.domain.model.ScreenPoint
import kotlinx.coroutines.flow.StateFlow

interface GazeRepository {
    val latest: StateFlow<GazeSample?>
    fun publish(sample: GazeSample)
    fun latestScreenPoint(): StateFlow<ScreenPoint?>
    fun reset()
    fun clear()
}
