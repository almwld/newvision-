# Troubleshooting

1. **Camera permission denied** — grant Camera in Android app settings, then return to NewVision.
2. **Overlay unavailable** — enable “Display over other apps”.
3. **Accessibility unavailable** — enable the NewVision accessibility service.
4. **Tracking has no point** — complete permissions and calibration first.
5. **Tracking is noisy** — recalibrate with stable head position and good lighting.
6. **Blink freezes the cursor** — this is intentional; reopen the eyes to resume.
7. **Dwell does not fire** — keep gaze within the configured radius for the configured duration.
8. **Dwell fires repeatedly** — verify the cooldown path is enabled and reset state after navigation.
9. **Calibration rejected** — collect enough valid samples at every target.
10. **Calibration feels offset** — run the full calibration again after changing device position.
11. **APK is rejected by Android** — use the signed release artifact; verify both v1 and v2 schemes.
12. **Debug APK is not installable** — ensure the device supports API 24 or newer.
13. **Release APK is too large** — inspect ABI split output and R8/resource shrinking.
14. **MediaPipe model missing** — run `scripts/fetch_face_landmarker.sh`.
15. **Flutter analyzer fails** — run `flutter pub get` and use Flutter 3.22 stable.
16. **Coverage gate fails** — add meaningful tests; do not lower the 70% threshold.
17. **Native tests fail** — run `cd android && gradle --no-daemon test`.
18. **EventChannel is silent** — verify the native gaze stream is initialized and the camera is running.
19. **Stale gaze sample appears** — samples with non-increasing timestamps are rejected.
20. **R8 release regression** — add a targeted keep rule only for the affected reflective/native contract and add a regression test where possible.
