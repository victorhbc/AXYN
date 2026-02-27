#!/bin/sh
# Run the Flutter app from repo root. The app lives in axys/.
cd "$(dirname "$0")/axys" && flutter run "$@"
