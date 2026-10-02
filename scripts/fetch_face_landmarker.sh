#!/usr/bin/env bash
set -euo pipefail

MODEL_URL="https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task"
MODEL_SHA256="64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff"

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
echo "MediaPipe Face Landmarker model verified and staged in all required asset paths."
