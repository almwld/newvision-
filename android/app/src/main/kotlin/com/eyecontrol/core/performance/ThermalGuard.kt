package com.eyecontrol.core.performance
import android.content.Context
import android.os.PowerManager
/** Provides a conservative thermal signal so callers can reduce camera workload. */
class ThermalGuard(context:Context){private val power=context.getSystemService(PowerManager::class.java)
 fun status():Int=if(android.os.Build.VERSION.SDK_INT>=29)power.currentThermalStatus else 0
 fun shouldReduceLoad():Boolean=status()>=PowerManager.THERMAL_STATUS_SEVERE
}