#!/usr/bin/env sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
ENV_FILE="$ROOT/config.local/miner.env"
UNAME_S=$(uname -s)

if [ ! -f "$ENV_FILE" ]; then
  echo "File config lokal belum ada: $ENV_FILE" >&2
  echo "Copy $ROOT/config/miner.env.example ke $ENV_FILE lalu isi wallet dan profile device." >&2
  return 1 2>/dev/null || exit 1
fi

# Parse KEY=VALUE manually so values with spaces do not break shell sourcing.
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    "" | \#* | \;*)
      continue
      ;;
  esac

  key=${line%%=*}
  value=${line#*=}

  key=$(printf '%s' "$key" | tr -d '[:space:]')
  value=$(printf '%s' "$value" | tr -d '\r')

  case "$value" in
    \"*\")
      value=${value#\"}
      value=${value%\"}
      ;;
    \'*\')
      value=${value#\'}
      value=${value%\'}
      ;;
  esac

  export "$key=$value"
done < "$ENV_FILE"

: "${COIN:?COIN wajib diisi di config.local/miner.env}"
: "${WALLET:?WALLET wajib diisi di config.local/miner.env}"

[ -n "${WORKER_NAME:-}" ] || WORKER_NAME=$(hostname)
[ -n "${LOL_WORKER_NAME:-}" ] || LOL_WORKER_NAME="$WORKER_NAME"
[ -n "${POOL_CPU:-}" ] || POOL_CPU="rx.unmineable.com:3333"
[ -n "${ALGO_CPU:-}" ] || ALGO_CPU="rx"
[ -n "${POOL_GPU:-}" ] || POOL_GPU="etchash.unmineable.com:3333"
[ -n "${ALGO_GPU:-}" ] || ALGO_GPU="ETCHASH"
[ -n "${PASSWORD:-}" ] || PASSWORD="x"
[ -n "${AUTOSTART_PROFILE:-}" ] || AUTOSTART_PROFILE="cpu"
[ -n "${XMRIG_THREADS:-}" ] || XMRIG_THREADS="2"
[ -n "${XMRIG_CPU_PRIORITY:-}" ] || XMRIG_CPU_PRIORITY="5"
[ -n "${XMRIG_PRINT_TIME:-}" ] || XMRIG_PRINT_TIME="60"
[ -n "${XMRIG_HEALTH_PRINT_TIME:-}" ] || XMRIG_HEALTH_PRINT_TIME="60"
[ -n "${XMRIG_DONATE_LEVEL:-}" ] || XMRIG_DONATE_LEVEL="1"
[ -n "${XMRIG_HUGE_PAGES_JIT:-}" ] || XMRIG_HUGE_PAGES_JIT="false"
[ -n "${LOL_API_PORT:-}" ] || LOL_API_PORT="8020"

if [ "$UNAME_S" = "Darwin" ]; then
  [ -n "${XMRIG_UNIX_BIN:-}" ] || XMRIG_UNIX_BIN="$ROOT/tools/xmrig/macos/xmrig"
  [ -n "${LOLMINER_UNIX_BIN:-}" ] || LOLMINER_UNIX_BIN="$ROOT/tools/lolminer/macos/lolMiner"
else
  [ -n "${XMRIG_UNIX_BIN:-}" ] || XMRIG_UNIX_BIN="$ROOT/tools/xmrig/linux/xmrig"
  [ -n "${LOLMINER_UNIX_BIN:-}" ] || LOLMINER_UNIX_BIN="$ROOT/tools/lolminer/linux/lolMiner"
fi

export ROOT ENV_FILE UNAME_S COIN WALLET PASSWORD WORKER_NAME LOL_WORKER_NAME AUTOSTART_PROFILE
export POOL_CPU ALGO_CPU POOL_GPU ALGO_GPU
export XMRIG_THREADS XMRIG_CPU_PRIORITY XMRIG_PRINT_TIME XMRIG_HEALTH_PRINT_TIME
export XMRIG_DONATE_LEVEL XMRIG_HUGE_PAGES_JIT LOL_API_PORT XMRIG_UNIX_BIN LOLMINER_UNIX_BIN
