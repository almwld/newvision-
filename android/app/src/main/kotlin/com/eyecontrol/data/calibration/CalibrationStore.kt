package com.eyecontrol.data.calibration

import android.content.Context

class CalibrationStore(context: Context) {
    private val preferences =
        context.getSharedPreferences("eye_control_calibration", Context.MODE_PRIVATE)

    fun read(): String? = preferences.getString(KEY_MODEL, null)

    fun write(model: String) {
        preferences.edit().putString(KEY_MODEL, model).apply()
    }

    fun clear() {
        preferences.edit().remove(KEY_MODEL).apply()
    }

    private companion object {
        const val KEY_MODEL = "ridge_model"
    }
}
