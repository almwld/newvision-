# NewVision

NewVision is a production-oriented Android eye-control application. Gaze estimation, filtering, calibration and interaction decisions are processed on-device.

## Pipeline
CameraX → MediaPipe Face Landmarker → iris normalization → Kalman + One-Euro smoothing → Ridge calibration → ScreenPoint → blink freeze → intent/dwell detection → overlay/accessibility gesture.

## Requirements
Flutter 3.22+, Dart 3.3+, JDK 17, Android SDK 34. Minimum Android API 24.

## Build
`flutter pub get`
`bash scripts/fetch_face_landmarker.sh`
`flutter analyze`
`flutter test`
`flutter build apk --release --split-per-abi --no-shrink`

Release signing is intentionally secret-backed; keystores are never committed.

## Documentation
- ARCHITECTURE.md
- CALIBRATION.md
- API.md
- TROUBLESHOOTING.md
- USER_GUIDE.md
- PERFORMANCE.md
- CONTRIBUTING.md
- CHANGELOG.md
