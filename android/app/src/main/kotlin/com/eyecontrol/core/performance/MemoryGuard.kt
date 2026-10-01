package com.eyecontrol.core.performance
import android.app.ActivityManager
import android.content.Context
/** Checks available memory before optional allocations; camera frames are never retained. */
class MemoryGuard(context:Context){private val manager=context.getSystemService(ActivityManager::class.java)
 fun isLowMemory():Boolean{val info=ActivityManager.MemoryInfo();manager.getMemoryInfo(info);return info.lowMemory}
}