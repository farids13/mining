#!/usr/bin/env sh
set -eu

SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SERVICE_FILE="$SERVICE_DIR/mining-portable.service"

systemctl --user disable --now mining-portable.service 2>/dev/null || true

if [ -f "$SERVICE_FILE" ]; then
  rm -f "$SERVICE_FILE"
fi

systemctl --user daemon-reload
echo "Autostart dimatikan."

