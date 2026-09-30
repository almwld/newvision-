# Platform API

Flutter communicates with Android through the platform channel named com.eyecontrol/platform.

| Method | Purpose |
|---|---|
| camera.start | Start CameraX analysis |
| camera.stop | Stop camera analysis |
| overlay.request | Request overlay permission |
| gesture.tap | Execute an accessibility tap |
| dwell.configure | Configure dwell duration and radius |

Native errors must be returned as typed platform exceptions. No platform failure is silently swallowed.
