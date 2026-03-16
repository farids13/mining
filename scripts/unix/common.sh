#!/usr/bin/env sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
GLOBAL_ENV_FILE="$ROOT/config/miner.env"
ENV_FILE="$ROOT/config.local/miner.env"
PROFILE_DIR="$ROOT/config.local/profiles"
UNAME_S=$(uname -s)

if [ ! -f "$GLOBAL_ENV_FILE" ]; then
  cp "$ROOT/config/miner.env.example" "$GLOBAL_ENV_FILE"
fi

if [ ! -f "$ENV_FILE" ]; then
  mkdir -p "$(dirname "$ENV_FILE")"
  cp "$GLOBAL_ENV_FILE" "$ENV_FILE"
  echo "Config lokal dibuat otomatis: $ENV_FILE" >&2
  echo "Basis config global diambil dari: $GLOBAL_ENV_FILE" >&2
fi

load_env_file() {
  file_path="$1"
  [ -f "$file_path" ] || return 0

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
  done < "$file_path"
}

is_placeholder_value() {
  value="${1:-}"
  case "$value" in
    "" | "REPLACE_WITH_YOUR_WALLET")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

load_env_file "$GLOBAL_ENV_FILE"
load_env_file "$ENV_FILE"

[ -n "${RUN_MODE:-}" ] || RUN_MODE="profile"
[ -n "${PROFILE_NAME:-}" ] || PROFILE_NAME="default"
[ -n "${XMRIG_CLI_ARGS:-}" ] || XMRIG_CLI_ARGS=""

profile_file="$PROFILE_DIR/$PROFILE_NAME.env"
if [ "$RUN_MODE" = "profile" ] && [ -f "$profile_file" ]; then
  BASE_WALLET="${WALLET:-}"
  load_env_file "$profile_file"
  if is_placeholder_value "${WALLET:-}" && ! is_placeholder_value "$BASE_WALLET"; then
    WALLET="$BASE_WALLET"
  fi
fi

: "${COIN:?COIN wajib diisi di config/miner.env atau config.local/miner.env}"
if is_placeholder_value "${WALLET:-}"; then
  echo "WALLET wajib diisi dengan alamat wallet asli di config.local/miner.env atau config.local/profiles/$PROFILE_NAME.env" >&2
  exit 1
fi

[ -n "${WORKER_NAME:-}" ] || WORKER_NAME=$(hostname)
[ -n "${LOL_WORKER_NAME:-}" ] || LOL_WORKER_NAME="$WORKER_NAME"
[ -n "${RIG_ID:-}" ] || RIG_ID=""
[ -n "${POOL_CPU:-}" ] || POOL_CPU="rx.unmineable.com:3333"
[ -n "${ALGO_CPU:-}" ] || ALGO_CPU="rx"
[ -n "${POOL_GPU:-}" ] || POOL_GPU="etchash.unmineable.com:3333"
[ -n "${ALGO_GPU:-}" ] || ALGO_GPU="ETCHASH"
[ -n "${PASSWORD:-}" ] || PASSWORD="x"
[ -n "${AUTOSTART_PROFILE:-}" ] || AUTOSTART_PROFILE="cpu"
[ -n "${XMRIG_THREADS:-}" ] || XMRIG_THREADS="2"
[ -n "${XMRIG_CPU_PRIORITY:-}" ] || XMRIG_CPU_PRIORITY="5"
[ -n "${XMRIG_CPU_AFFINITY:-}" ] || XMRIG_CPU_AFFINITY=""
[ -n "${XMRIG_PRINT_TIME:-}" ] || XMRIG_PRINT_TIME="60"
[ -n "${XMRIG_HEALTH_PRINT_TIME:-}" ] || XMRIG_HEALTH_PRINT_TIME="60"
[ -n "${XMRIG_DONATE_LEVEL:-}" ] || XMRIG_DONATE_LEVEL="1"
[ -n "${XMRIG_HUGE_PAGES_JIT:-}" ] || XMRIG_HUGE_PAGES_JIT="false"
[ -n "${XMRIG_EXTRA_ARGS:-}" ] || XMRIG_EXTRA_ARGS=""
[ -n "${LOL_API_PORT:-}" ] || LOL_API_PORT="8020"
[ -n "${LOL_EXTRA_ARGS:-}" ] || LOL_EXTRA_ARGS=""

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
export GLOBAL_ENV_FILE PROFILE_DIR RUN_MODE PROFILE_NAME XMRIG_CLI_ARGS
