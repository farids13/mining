#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SERVICE_FILE="$SERVICE_DIR/mining-portable.service"

mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Portable mining launcher
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
ExecStart=$SCRIPT_DIR/start-profile.sh
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now mining-portable.service
echo "Autostart aktif: $SERVICE_FILE"

