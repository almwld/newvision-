# Performance

The runtime is designed around a 30 FPS analysis target and a 60 FPS UI target.

CameraX uses KEEP_ONLY_LATEST to prevent frame backlog. PerformanceMonitor records frame rate and analysis latency without retaining images. ThermalGuard exposes severe thermal state, MemoryGuard detects system low-memory conditions, CameraRecovery provides bounded retry, and BackgroundHandler owns cancellable background work.

For performance testing, measure sustained FPS, average analysis latency, dropped-frame behavior and thermal state on the target device rather than relying on a single startup measurement.
