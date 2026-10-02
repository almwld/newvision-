#!/usr/bin/env bash
set -euo pipefail

MODEL_URL="https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task"
MODEL_SHA256="64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff"
MODEL_PATH="android/app/src/main/assets/face_landmarker.task"

mkdir -p "$(dirname "$MODEL_PATH")"
curl --fail --location --retry 3 --connect-timeout 20 "$MODEL_URL" -o "$MODEL_PATH"

printf '%s  %s\n' "$MODEL_SHA256" "$MODEL_PATH" | sha256sum --check --status
echo "MediaPipe Face Landmarker model verified."
