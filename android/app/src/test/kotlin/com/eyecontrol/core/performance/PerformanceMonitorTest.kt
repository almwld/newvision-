package com.eyecontrol.core.performance
import org.junit.Assert.assertEquals
import org.junit.Test
class PerformanceMonitorTest{ @Test fun recordsFrames(){var now=0L;val m=PerformanceMonitor{now};m.recordFrame(10_000_000);now=1_000_000_000;m.recordFrame(20_000_000);val s=m.snapshot();assertEquals(2.0,s.fps,0.001);assertEquals(15.0,s.averageLatencyMs,0.001)}}