#!/usr/bin/env sh
set -eu

PLIST_FILE="$HOME/Library/LaunchAgents/com.fast.mining-portable.plist"
DOMAIN_TARGET="gui/$(id -u)"

launchctl bootout "$DOMAIN_TARGET" "$PLIST_FILE" >/dev/null 2>&1 || true
if [ -f "$PLIST_FILE" ]; then
  rm -f "$PLIST_FILE"
fi

echo "Autostart dimatikan."
