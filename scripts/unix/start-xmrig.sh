#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

if [ ! -x "$XMRIG_UNIX_BIN" ]; then
  echo "Binary XMRig tidak ditemukan atau tidak executable: $XMRIG_UNIX_BIN" >&2
  if [ "$UNAME_S" = "Darwin" ]; then
    echo "Letakkan binary macOS di $ROOT/tools/xmrig/macos/xmrig atau isi XMRIG_UNIX_BIN di config.local/miner.env" >&2
  fi
  exit 1
fi

USER_SPEC="$COIN:$WALLET.$WORKER_NAME"
set -- "$XMRIG_UNIX_BIN" -o "$POOL_CPU" -a "$ALGO_CPU" -k -u "$USER_SPEC" -p "$PASSWORD" \
  --threads="$XMRIG_THREADS" --cpu-priority="$XMRIG_CPU_PRIORITY" \
  --print-time="$XMRIG_PRINT_TIME" \
  --donate-level="$XMRIG_DONATE_LEVEL"

if [ "${XMRIG_HUGE_PAGES_JIT}" = "true" ]; then
  set -- "$@" --huge-pages-jit
fi

if [ -n "${XMRIG_CPU_AFFINITY:-}" ]; then
  set -- "$@" --cpu-affinity="$XMRIG_CPU_AFFINITY"
fi

if [ -n "${RIG_ID:-}" ]; then
  set -- "$@" --rig-id="$RIG_ID"
fi

if [ -n "${XMRIG_EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" $XMRIG_EXTRA_ARGS
fi

cd "$(dirname "$XMRIG_UNIX_BIN")"
exec "$@"
