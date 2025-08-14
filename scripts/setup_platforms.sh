#!/usr/bin/env bash
set -euo pipefail
flutter --version
flutter pub get
# Add platform folders if you want to commit them:
flutter create . --platforms=android,ios,web,macos,windows,linux
echo "Done. You can now open android/ios/... or build targets."
