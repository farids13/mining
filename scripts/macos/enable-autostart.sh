#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$LAUNCH_AGENTS_DIR/com.fast.mining-portable.plist"
DOMAIN_TARGET="gui/$(id -u)"

mkdir -p "$LAUNCH_AGENTS_DIR"

cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.fast.mining-portable</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_DIR/start-profile.sh</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$ROOT</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

launchctl bootout "$DOMAIN_TARGET" "$PLIST_FILE" >/dev/null 2>&1 || true
if launchctl bootstrap "$DOMAIN_TARGET" "$PLIST_FILE"; then
  echo "Autostart aktif: $PLIST_FILE"
else
  echo "File LaunchAgent sudah dibuat: $PLIST_FILE" >&2
  echo "Tetapi launchctl gagal memuat service di environment ini." >&2
  exit 1
fi
