package com.eyecontrol.core.performance
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
/** Owns non-UI work and is cancelled with the component that creates it. */
class BackgroundHandler{private val job=SupervisorJob();val scope=CoroutineScope(Dispatchers.Default+job);fun close(){job.cancel()}}