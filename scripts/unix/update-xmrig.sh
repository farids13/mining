#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
DOWNLOAD_PAGE="https://xmrig.com/download"
TMP_DIR=${TMPDIR:-/tmp}
WORK_DIR=$(mktemp -d "$TMP_DIR/xmrig-update.XXXXXX")

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT INT TERM

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Command wajib tidak ditemukan: $1" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd tar
require_cmd uname

OS_NAME=$(uname -s)
ARCH_NAME=$(uname -m)
TARGET_DIR=""
EXPECTED_ASSET=""

set_target_by_choice() {
  choice="$1"
  case "$choice" in
    windows)
      TARGET_DIR="$ROOT/tools/xmrig/windows"
      EXPECTED_ASSET="zip"
      ;;
    linux)
      TARGET_DIR="$ROOT/tools/xmrig/linux"
      EXPECTED_ASSET="targz"
      ;;
    macos)
      TARGET_DIR="$ROOT/tools/xmrig/macos"
      EXPECTED_ASSET="targz"
      ;;
    *)
      return 1
      ;;
  esac
  mkdir -p "$TARGET_DIR"
  return 0
}

case "$OS_NAME" in
  Darwin)
    TARGET_DIR="$ROOT/tools/xmrig/macos"
    case "$ARCH_NAME" in
      arm64|aarch64)
        PLATFORM_SUFFIX="macos-arm64.tar.gz"
        ;;
      x86_64)
        PLATFORM_SUFFIX="macos-x64.tar.gz"
        ;;
      *)
        echo "Arsitektur macOS belum didukung otomatis: $ARCH_NAME" >&2
        PLATFORM_SUFFIX=""
        ;;
    esac
    ;;
  Linux)
    TARGET_DIR="$ROOT/tools/xmrig/linux"
    case "$ARCH_NAME" in
      x86_64|amd64)
        PLATFORM_SUFFIX="linux-static-x64.tar.gz"
        ;;
      *)
        echo "Arsitektur Linux belum didukung otomatis: $ARCH_NAME" >&2
        PLATFORM_SUFFIX=""
        ;;
    esac
    ;;
  *)
    echo "OS tidak didukung oleh updater ini: $OS_NAME" >&2
    exit 1
    ;;
esac

mkdir -p "$TARGET_DIR"

infer_target_from_asset() {
  asset_name="$1"
  case "$asset_name" in
    *windows-x64.zip)
      set_target_by_choice windows
      ;;
    *linux-static-x64.tar.gz)
      set_target_by_choice linux
      ;;
    *macos-arm64.tar.gz|*macos-x64.tar.gz)
      set_target_by_choice macos
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

prompt_target_choice() {
  echo "Target OS tidak bisa dideteksi dari nama file." >&2
  echo "[1] Windows" >&2
  echo "[2] Linux" >&2
  echo "[3] macOS" >&2
  printf "Pilih target OS [1/2/3]: " >&2
  read -r target_choice
  case "$target_choice" in
    1) set_target_by_choice windows ;;
    2) set_target_by_choice linux ;;
    3) set_target_by_choice macos ;;
    *)
      echo "Pilihan target OS tidak valid." >&2
      exit 1
      ;;
  esac
}

detect_asset_url() {
  page_file="$WORK_DIR/download.html"
  curl -fsSL "$DOWNLOAD_PAGE" -o "$page_file"

  latest_version=$(sed -n 's/.*Latest XMRig version is[[:space:]]*\([0-9][0-9.]*\).*/\1/p' "$page_file" | head -n 1)
  if [ -z "${latest_version:-}" ]; then
    return 1
  fi

  if [ -z "${PLATFORM_SUFFIX:-}" ]; then
    return 1
  fi

  asset_name="xmrig-$latest_version-$PLATFORM_SUFFIX"
  asset_url="https://github.com/xmrig/xmrig/releases/download/v$latest_version/$asset_name"
  printf '%s\n' "$asset_url"
}

prompt_local_file() {
  echo "Download otomatis gagal atau tidak tersedia." >&2
  echo "Silakan download manual dari: $DOWNLOAD_PAGE" >&2
  echo "Anda bisa isi salah satu:" >&2
  echo "- path file archive lokal" >&2
  echo "- URL direct download GitHub release" >&2
  printf 'Masukkan path file atau URL XMRig: ' >&2
  read -r source_input

  if [ -z "${source_input:-}" ]; then
    echo "Input tidak boleh kosong." >&2
    exit 1
  fi

  case "$source_input" in
    http://*|https://*)
      archive_file="$WORK_DIR/$(basename "$source_input")"
      echo "Mencoba download dari URL yang Anda input: $source_input" >&2
      if curl -fL "$source_input" -o "$archive_file"; then
        printf '%s\n' "$archive_file"
        return 0
      fi
      echo "Gagal download dari URL: $source_input" >&2
      exit 1
      ;;
    *)
      if [ ! -f "$source_input" ]; then
        echo "File archive tidak ditemukan: $source_input" >&2
        exit 1
      fi
      printf '%s\n' "$source_input"
      ;;
  esac
}

download_archive() {
  if asset_url=$(detect_asset_url 2>/dev/null); then
    archive_file="$WORK_DIR/$(basename "$asset_url")"
    echo "Mencoba download otomatis dari: $asset_url"
    if curl -fL "$asset_url" -o "$archive_file"; then
      printf '%s\n' "$archive_file"
      return 0
    fi
  fi

  prompt_local_file
}

extract_archive() {
  archive_path="$1"
  extract_dir="$WORK_DIR/extracted"
  mkdir -p "$extract_dir"

  case "$archive_path" in
    *.tar.gz)
      tar -xzf "$archive_path" -C "$extract_dir"
      ;;
    *.zip)
      require_cmd unzip
      unzip -q "$archive_path" -d "$extract_dir"
      ;;
    *)
      echo "Format archive belum didukung: $archive_path" >&2
      exit 1
      ;;
  esac

  binary_path=$(find "$extract_dir" -type f \( -name xmrig -o -name xmrig.exe \) | head -n 1)
  if [ -z "${binary_path:-}" ]; then
    echo "Binary xmrig tidak ditemukan di archive: $archive_path" >&2
    exit 1
  fi

  printf '%s\n' "$binary_path"
}

archive_path=$(download_archive)
if ! infer_target_from_asset "$(basename "$archive_path")"; then
  prompt_target_choice
fi
binary_path=$(extract_archive "$archive_path")

case "$binary_path" in
  *.exe)
    cp "$binary_path" "$TARGET_DIR/xmrig.exe"
    chmod +x "$TARGET_DIR/xmrig.exe" 2>/dev/null || true
    active_binary="$TARGET_DIR/xmrig.exe"
    ;;
  *)
    cp "$binary_path" "$TARGET_DIR/xmrig"
    chmod +x "$TARGET_DIR/xmrig"
    active_binary="$TARGET_DIR/xmrig"
    ;;
esac

echo "Update selesai."
echo "Binary aktif: $active_binary"
echo "Sumber resmi: $DOWNLOAD_PAGE"
