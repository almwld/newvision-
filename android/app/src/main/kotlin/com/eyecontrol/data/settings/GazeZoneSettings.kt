package com.eyecontrol.data.settings

data class GazeZoneSettings(
    val enabled: Boolean = false,
    val scrollUpEnabled: Boolean = false,
    val scrollDownEnabled: Boolean = false,
    val scrollLeftEnabled: Boolean = false,
    val scrollRightEnabled: Boolean = false,
    val fastClickEnabled: Boolean = false,
    val edgeThreshold: Float = 0.15f,
    val activationMs: Long = 300L,
    val cooldownMs: Long = 250L,
    val fastClickMs: Long = 250L,
) {
    init {
        require(edgeThreshold in 0.05f..0.45f)
        require(activationMs in 100L..2000L)
        require(cooldownMs in 100L..3000L)
        require(fastClickMs in 150L..500L)
    }
}
