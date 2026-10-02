# Troubleshooting

## Camera does not start
Grant Camera permission, then confirm Overlay and Accessibility are enabled. Return to the app so PermissionProvider can refresh readiness.

## Cursor is inaccurate
Clear calibration, confirm good lighting, keep the face inside the camera view and complete all nine targets without blinking during sampling.

## No gaze events
Verify the MediaPipe model was fetched with `scripts/fetch_face_landmarker.sh` and rebuild the Android app.

## Release signing fails
Configure GitHub Actions secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Never commit the keystore.
