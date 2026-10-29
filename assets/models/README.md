# On-device vision models

## MediaPipe Face Landmarker
The binary `face_landmarker.task` is provisioned by `scripts/fetch_face_landmarker.sh` during CI. Do not replace it with a dummy model.

## L2CS gaze model
Place the real, compatible L2CS TensorFlow Lite model at:

`assets/models/gaze_fp16.tflite`

The model contract is FLOAT32 input `[1, 3, 448, 448]` in NCHW order, with two FLOAT32 outputs (yaw and pitch), each shaped `[1, 90]` or `[90]`. Input values use RGB ImageNet mean/std normalization after scaling pixels to `[0, 1]`.

The binary model is not checked into this repository. If it is absent from the Flutter asset bundle, NewVision keeps MediaPipe iris tracking available and uses the iris-feature calibration path. To use L2CS angle-based calibration, include the genuine model before building; never substitute a placeholder or synthetic model.
