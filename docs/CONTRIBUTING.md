# Contributing

## Development

1. Use Flutter 3.22 stable and JDK 17.
2. Run `flutter analyze` and `flutter test --coverage`.
3. Run Android unit tests before changing native gaze code.
4. Keep native/Flutter contracts stable unless the change explicitly updates both sides.
5. Add tests for calibration, timestamp ordering, blink behavior and dwell changes.

## Commits

Use focused commits such as `feat(pipeline): ...`, `fix(ui): ...`, `test: ...`, `perf: ...` and `docs: ...`.

## Safety

Do not add camera frames, personal data or signing credentials to the repository. Release keystore material must remain in GitHub Actions secrets.
