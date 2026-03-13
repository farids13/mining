#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

PROFILE="${1:-$AUTOSTART_PROFILE}"

case "$PROFILE" in
  cpu)
    exec "$SCRIPT_DIR/start-xmrig.sh"
    ;;
  gpu)
    exec "$SCRIPT_DIR/start-lolminer.sh"
    ;;
  both)
    "$SCRIPT_DIR/start-xmrig.sh" &
    exec "$SCRIPT_DIR/start-lolminer.sh"
    ;;
  *)
    echo "Profile tidak valid: $PROFILE" >&2
    echo "Gunakan cpu, gpu, atau both." >&2
    exit 1
    ;;
esac

