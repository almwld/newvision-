# Performance

NewVision uses CameraX and MediaPipe for on-device eye tracking.

## Runtime
- Lifecycle-aware camera processing.
- Bounded camera recovery retries.
- Thermal workload protection.
- Memory/resource cleanup.

## Build
Release builds use R8/resource shrinking and ABI splits for armeabi-v7a, arm64-v8a and x86_64.

## Measuring
CI publishes Flutter coverage. APK size is measured from produced release artifacts.
