# NewVision

Production-oriented on-device eye control for Android using Flutter, CameraX and MediaPipe.

## Highlights
- Nine-point gaze calibration.
- Four-feature ridge calibration.
- Blink-aware screen-point pipeline.
- Fixation, saccade and smooth-pursuit intent detection.
- Dwell-based tap with cooldown.
- Camera/overlay/accessibility readiness checks.
- On-device camera processing.

## Development

    flutter pub get
    flutter analyze
    flutter test --coverage
    cd android && ./gradlew test assembleDebug

## Release
Tagged releases build split APKs and an Android App Bundle. Release signing is supplied through GitHub Actions secrets; no keystore is stored in the repository.

See `docs/ARCHITECTURE.md`, `docs/CALIBRATION.md`, `docs/API.md`, `docs/PERFORMANCE.md`, `docs/PRIVACY.md`, `docs/TROUBLESHOOTING.md` and `docs/USER_GUIDE.md`.
