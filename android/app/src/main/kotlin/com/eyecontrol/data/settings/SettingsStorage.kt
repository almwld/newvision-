package com.eyecontrol.data.settings

import android.content.SharedPreferences

class SettingsStorage(private val prefs: SharedPreferences) {
    companion object {
        private const val ENABLED = "gaze_zones_enabled"
        private const val UP = "scroll_up"
        private const val DOWN = "scroll_down"
        private const val LEFT = "scroll_left"
        private const val RIGHT = "scroll_right"
        private const val FAST = "fast_click"
        private const val EDGE = "edge_threshold"
        private const val ACTIVATION = "activation_ms"
        private const val COOLDOWN = "cooldown_ms"
        private const val FAST_MS = "fast_click_ms"
    }

    fun load(): GazeZoneSettings = GazeZoneSettings(
        enabled = prefs.getBoolean(ENABLED, false),
        scrollUpEnabled = prefs.getBoolean(UP, false),
        scrollDownEnabled = prefs.getBoolean(DOWN, false),
        scrollLeftEnabled = prefs.getBoolean(LEFT, false),
        scrollRightEnabled = prefs.getBoolean(RIGHT, false),
        fastClickEnabled = prefs.getBoolean(FAST, false),
        edgeThreshold = prefs.getFloat(EDGE, 0.15f),
        activationMs = prefs.getLong(ACTIVATION, 300L),
        cooldownMs = prefs.getLong(COOLDOWN, 250L),
        fastClickMs = prefs.getLong(FAST_MS, 250L),
    )

    fun save(settings: GazeZoneSettings) {
        prefs.edit()
            .putBoolean(ENABLED, settings.enabled)
            .putBoolean(UP, settings.scrollUpEnabled)
            .putBoolean(DOWN, settings.scrollDownEnabled)
            .putBoolean(LEFT, settings.scrollLeftEnabled)
            .putBoolean(RIGHT, settings.scrollRightEnabled)
            .putBoolean(FAST, settings.fastClickEnabled)
            .putFloat(EDGE, settings.edgeThreshold)
            .putLong(ACTIVATION, settings.activationMs)
            .putLong(COOLDOWN, settings.cooldownMs)
            .putLong(FAST_MS, settings.fastClickMs)
            .apply()
    }

    fun reset(): GazeZoneSettings {
        val defaults = GazeZoneSettings()
        save(defaults)
        return defaults
    }
}
