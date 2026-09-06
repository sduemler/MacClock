#!/bin/zsh
# Builds MacClock in release mode, assembles MacClock.app, and ad-hoc signs it.
#   ./build.sh            -> build/MacClock.app
#   ./build.sh --install  -> also copies to /Applications and relaunches
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release --arch arm64 --arch x86_64 --product MacClock

APP=build/MacClock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/apple/Products/Release/MacClock "$APP/Contents/MacOS/MacClock"
cp Resources/Info.plist "$APP/Contents/Info.plist"
[ -f Resources/AppIcon.icns ] && cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
echo -n "APPL????" > "$APP/Contents/PkgInfo"

codesign --force --sign - "$APP"
echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
  pkill -x MacClock || true
  rm -rf /Applications/MacClock.app
  cp -R "$APP" /Applications/MacClock.app
  open /Applications/MacClock.app
  echo "Installed to /Applications/MacClock.app"
fi
