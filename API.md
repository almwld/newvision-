# Native API

## MethodChannel
Channel: `com.eyecontrol/platform`

Key methods include `camera.start`, `camera.stop`, `overlay.isGranted`, `overlay.request`, `accessibility.isEnabled`, `accessibility.request`, `gaze.latest`, `calibration.fit`, `calibration.predict`, `calibration.clear`, `dwell.configure` and `gesture.tap`.

## EventChannel
Channel: `com.eyecontrol/gaze_screen_point`

Events contain `xPx`, `yPx`, `confidence`, `isBlinking` and `timestampNs`.

ScreenPoint is the public tracking contract; raw camera frames never cross the Flutter boundary.
