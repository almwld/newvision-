# Architecture

The project keeps the gaze pipeline native because CameraX and MediaPipe are latency-sensitive. Flutter owns presentation, navigation and settings.

## Boundaries
**Domain:** GazeSample, ScreenPoint, EyeFeatures, repositories and use cases.

**Data:** CameraX, MediaPipe analyzer, filters, calibration persistence and native repositories.

**Interaction:** intent detection, dwell state, overlay cursor and accessibility gesture execution.

**Flutter:** GoRouter, Provider state, native MethodChannel/EventChannel bridge and Material 3 UI.

No camera image is persisted or uploaded. ScreenPoint is the contract crossing into Flutter.

## Performance
Camera analysis uses a single-thread executor and KEEP_ONLY_LATEST backpressure. UI state is published through a conflated event stream.
