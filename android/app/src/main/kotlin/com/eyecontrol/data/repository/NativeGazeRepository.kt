package com.eyecontrol.data.repository

import com.eyecontrol.domain.model.GazeFrame
import com.eyecontrol.domain.repository.GazeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class NativeGazeRepository : GazeRepository {
    private val _latest = MutableStateFlow<GazeFrame?>(null)
    override val latest: StateFlow<GazeFrame?> = _latest.asStateFlow()

    override fun publish(frame: GazeFrame) {
        _latest.value = frame
    }

    override fun clear() {
        _latest.value = null
    }
}
