package com.eyecontrol.core.performance
import java.util.concurrent.atomic.AtomicLong
/** Tracks lightweight frame throughput and analysis latency without retaining frames. */
class PerformanceMonitor(private val clockNs: () -> Long = System::nanoTime) {
 private val frames=AtomicLong(0); private var windowStart=clockNs(); private var latencyTotal=0L
 @Synchronized fun recordFrame(analysisLatencyNs:Long){frames.incrementAndGet();latencyTotal+=analysisLatencyNs}
 @Synchronized fun snapshot():Snapshot{val now=clockNs();val seconds=((now-windowStart).coerceAtLeast(1L))/1_000_000_000.0;val count=frames.get();return Snapshot(if(seconds>0)count/seconds else 0.0,if(count>0)latencyTotal.toDouble()/count/1_000_000.0 else 0.0)}
 data class Snapshot(val fps:Double,val averageLatencyMs:Double)
 @Synchronized fun reset(){frames.set(0);latencyTotal=0;windowStart=clockNs()}
}