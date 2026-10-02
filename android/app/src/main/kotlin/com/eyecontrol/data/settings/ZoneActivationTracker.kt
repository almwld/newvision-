package com.eyecontrol.data.settings

import kotlin.math.max
import kotlin.math.min

sealed interface ZoneActivationResult {
    data object None : ZoneActivationResult
    data class Active(val progress: Float) : ZoneActivationResult
    data object Activated : ZoneActivationResult
}

class ZoneActivationTracker(
    activationMs: Long = 300L,
    cooldownMs: Long = 250L,
    private val clockMs: () -> Long = { System.nanoTime() / 1_000_000L },
) {
    private var activationMs = activationMs
    private var cooldownMs = cooldownMs
    private var activeZone: GazeZone? = null
    private var startedAt = 0L
    private var cooldownUntil = 0L

    init {
        require(activationMs > 0)
        require(cooldownMs >= 0)
    }

    fun configure(activationMs: Long, cooldownMs: Long) {
        require(activationMs > 0)
        require(cooldownMs >= 0)
        this.activationMs = activationMs
        this.cooldownMs = cooldownMs
        reset()
    }

    fun update(zone: GazeZone?): ZoneActivationResult {
        val now = clockMs()
        if (zone == null) {
            resetAnchor()
            return ZoneActivationResult.None
        }
        if (now < cooldownUntil) return ZoneActivationResult.None

        if (zone != activeZone) {
            activeZone = zone
            startedAt = now
            return ZoneActivationResult.Active(0f)
        }

        val elapsed = max(0L, now - startedAt)
        if (elapsed >= activationMs) {
            cooldownUntil = now + cooldownMs
            resetAnchor()
            return ZoneActivationResult.Activated
        }

        return ZoneActivationResult.Active(
            min(1f, elapsed.toFloat() / activationMs.toFloat()),
        )
    }

    fun reset() {
        activeZone = null
        startedAt = 0L
        cooldownUntil = 0L
    }

    private fun resetAnchor() {
        activeZone = null
        startedAt = 0L
    }
}
