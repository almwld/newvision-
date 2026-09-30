# Contributing

Keep Presentation dependent on Domain abstractions. Keep Android-specific behavior in Platform/Data layers. Preserve camera, gaze, calibration, accessibility and overlay behavior. Add tests for behavior changes.

Before submitting, run `flutter analyze`, `flutter test --coverage`, and Android unit tests. Never commit keystores, credentials, API tokens or generated signing material.
