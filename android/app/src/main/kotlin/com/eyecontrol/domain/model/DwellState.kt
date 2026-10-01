package com.eyecontrol.domain.model

data class DwellState(
    val progress: Float,
    val fired: Boolean,
    val cancelled: Boolean,
)
