#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

if [ ! -x "$LOLMINER_UNIX_BIN" ]; then
  echo "Binary lolMiner tidak ditemukan atau tidak executable: $LOLMINER_UNIX_BIN" >&2
  if [ "$UNAME_S" = "Darwin" ]; then
    echo "Letakkan binary macOS di $ROOT/tools/lolminer/macos/lolMiner atau isi LOLMINER_UNIX_BIN di config.local/miner.env" >&2
  else
    echo "Letakkan binary Linux di path tersebut atau isi LOLMINER_UNIX_BIN di config.local/miner.env" >&2
  fi
  exit 1
fi

USER_SPEC="$COIN:$WALLET"
set -- "$LOLMINER_UNIX_BIN" --algo "$ALGO_GPU" --pool "$POOL_GPU" --user "$USER_SPEC" \
  --worker "$LOL_WORKER_NAME" --apiport "$LOL_API_PORT"

if [ -n "${LOL_EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" $LOL_EXTRA_ARGS
fi

cd "$(dirname "$LOLMINER_UNIX_BIN")"
exec "$@"
