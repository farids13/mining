#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OS_NAME=$(uname -s)
PROFILE="${1:-}"

case "$OS_NAME" in
  Linux)
    if [ -n "$PROFILE" ]; then
      exec "$ROOT_DIR/scripts/linux/start-profile.sh" "$PROFILE"
    fi
    exec "$ROOT_DIR/scripts/unix/dashboard.sh"
    ;;
  Darwin)
    if [ -n "$PROFILE" ]; then
      exec "$ROOT_DIR/scripts/macos/start-profile.sh" "$PROFILE"
    fi
    exec "$ROOT_DIR/scripts/unix/dashboard.sh"
    ;;
  *)
    echo "OS tidak didukung oleh run.sh: $OS_NAME" >&2
    echo "Gunakan Windows launcher jika Anda berada di Windows." >&2
    exit 1
    ;;
esac
