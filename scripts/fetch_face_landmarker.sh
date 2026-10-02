#!/usr/bin/env bash
set -euo pipefail

MODEL_URL="https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task"
MODEL_SHA256="64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff"
L2CS_MODEL_URL="https://huggingface.co/litert-community/L2CS-Gaze360-LiteRT/resolve/main/gaze_fp16.tflite"

# Keep the downloaded model in both Flutter and Android-native asset locations.
# MediaPipe's BaseOptions.setModelAssetPath() resolves Android assets, while
# Flutter bundles its own assets under flutter_assets.
MODEL_PATHS=(
  "assets/face_landmarker.task"
  "assets/models/face_landmarker.task"
  "android/app/src/main/assets/face_landmarker.task"
  "android/app/src/main/assets/models/face_landmarker.task"
  "android/app/src/main/assets/assets/models/face_landmarker.task"
)

TMP_MODEL="$(mktemp)"
trap 'rm -f "$TMP_MODEL"' EXIT

curl --fail --location --retry 3 --connect-timeout 20 "$MODEL_URL" -o "$TMP_MODEL"
printf '%s  %s\n' "$MODEL_SHA256" "$TMP_MODEL" | sha256sum --check --status

for MODEL_PATH in "${MODEL_PATHS[@]}"; do
  mkdir -p "$(dirname "$MODEL_PATH")"
  cp "$TMP_MODEL" "$MODEL_PATH"
done

ls -lh "${MODEL_PATHS[@]}"
# L2CS-Gaze360 LiteRT model is downloaded at build time rather than committed as a large binary.
# This keeps the Git repository lightweight while ensuring release/debug builds contain the exact model.
L2CS_TMP="$(mktemp)"
trap 'rm -f "$TMP_MODEL" "$L2CS_TMP"' EXIT
curl --fail --location --retry 3 --connect-timeout 20 "$L2CS_MODEL_URL" -o "$L2CS_TMP"
L2CS_SIZE="$(stat -c%s "$L2CS_TMP")"
if [ "$L2CS_SIZE" -lt 45000000 ] || [ "$L2CS_SIZE" -gt 55000000 ]; then
  echo "Unexpected L2CS model size: $L2CS_SIZE bytes" >&2
  exit 1
fi
mkdir -p android/app/src/main/assets/models
cp "$L2CS_TMP" android/app/src/main/assets/models/gaze_fp16.tflite
ls -lh android/app/src/main/assets/models/gaze_fp16.tflite
echo "MediaPipe Face Landmarker and L2CS-Gaze360 models verified and staged."
