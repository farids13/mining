#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
. "$SCRIPT_DIR/common.sh"

if ! [[ -t 0 && -t 1 ]]; then
  echo "Dashboard interaktif butuh terminal TTY." >&2
  echo "Jalankan langsung dari terminal, misalnya: ./run.sh" >&2
  exit 1
fi

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_TITLE=$'\033[1;36m'
  C_LABEL=$'\033[38;5;223m'
  C_VALUE=$'\033[1;37m'
  C_OK=$'\033[1;32m'
  C_MENU=$'\033[38;5;81m'
  C_WARN=$'\033[1;31m'
  C_DIM=$'\033[2m'
  C_PANEL=$'\033[38;5;45m'
  C_HOT=$'\033[1;95m'
  C_SELECT=$'\033[1;96m'
else
  C_RESET=""
  C_TITLE=""
  C_LABEL=""
  C_VALUE=""
  C_OK=""
  C_MENU=""
  C_WARN=""
  C_DIM=""
  C_PANEL=""
  C_HOT=""
  C_SELECT=""
fi

hr() {
  printf "%s────────────────────────────────────────────────────────%s\n" "$C_PANEL" "$C_RESET"
}

clear_screen() {
  if [[ -t 1 ]]; then
    printf '\033[2J\033[H'
  fi
}

panel_title() {
  printf "%s%s%s\n" "$C_TITLE" "$1" "$C_RESET"
}

status_line() {
  local label="$1"
  local value="$2"
  local color="$3"
  printf "%s%-18s%s %b%s%b\n" "$C_LABEL" "$label" "$C_RESET" "$color" "$value" "$C_RESET"
}

binary_status() {
  local path="$1"
  if [[ -x "$path" ]]; then
    printf '%bready%b' "$C_OK" "$C_RESET"
  else
    printf '%bmissing%b' "$C_WARN" "$C_RESET"
  fi
}

autostart_status() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    if [[ -f "$HOME/Library/LaunchAgents/com.fast.mining-portable.plist" ]]; then
      printf '%bconfigured%b' "$C_OK" "$C_RESET"
    else
      printf '%boff%b' "$C_WARN" "$C_RESET"
    fi
  else
    if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/mining-portable.service" ]]; then
      printf '%bconfigured%b' "$C_OK" "$C_RESET"
    else
      printf '%boff%b' "$C_WARN" "$C_RESET"
    fi
  fi
}

detect_logical_cpu() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    sysctl -n hw.logicalcpu 2>/dev/null || echo 4
  else
    getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4
  fi
}

calc_threads_from_percent() {
  local percent="$1"
  local total_cpu
  total_cpu=$(detect_logical_cpu)
  if [[ -z "$percent" ]]; then
    echo "$XMRIG_THREADS"
    return
  fi
  if ! [[ "$percent" =~ ^[0-9]+$ ]] || (( percent < 1 || percent > 100 )); then
    echo "$XMRIG_THREADS"
    return
  fi
  local threads=$((total_cpu * percent / 100))
  if (( threads < 1 )); then
    threads=1
  fi
  echo "$threads"
}

prompt_default() {
  local label="$1"
  local current="$2"
  printf "%s [%s]: " "$label" "$current" >&2
  IFS= read -r value
  if [[ -n "${value:-}" ]]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$current"
  fi
}

choose_option() {
  local title="$1"
  shift
  local options=("$@")
  local selected=0
  local key

  while true; do
    clear_screen
    panel_title "MINING CONTROL CENTER"
    printf "%sPortable desktop miner setup%s\n" "$C_DIM" "$C_RESET"
    hr
    panel_title "$title"
    printf "%sGunakan panah atas/bawah lalu Enter untuk memilih.%s\n" "$C_DIM" "$C_RESET"
    hr

    local i
    for i in "${!options[@]}"; do
      if [[ "$i" -eq "$selected" ]]; then
        printf "%b> %s%b\n" "$C_SELECT" "${options[$i]}" "$C_RESET" >&2
      else
        printf "  %s\n" "${options[$i]}" >&2
      fi
    done
    hr >&2

    IFS= read -rsn1 key
    if [[ "$key" == $'\x1b' ]]; then
      IFS= read -rsn2 key || true
      case "$key" in
        '[A')
          ((selected--))
          if (( selected < 0 )); then selected=$((${#options[@]} - 1)); fi
          ;;
        '[B')
          ((selected++))
          if (( selected >= ${#options[@]} )); then selected=0; fi
          ;;
      esac
    elif [[ "$key" == "" ]]; then
      CHOOSE_RESULT="${options[$selected]}"
      return
    fi
  done
}

save_config() {
  mkdir -p "$ROOT/config.local"
  cat > "$ENV_FILE" <<EOF
COIN=$COIN
WALLET=$WALLET
PASSWORD=$PASSWORD
WORKER_NAME=$WORKER_NAME
RIG_ID=$RIG_ID
AUTOSTART_PROFILE=$AUTOSTART_PROFILE
RUN_MODE=$RUN_MODE
PROFILE_NAME=$PROFILE_NAME
XMRIG_CLI_ARGS=$XMRIG_CLI_ARGS

POOL_CPU=$POOL_CPU
ALGO_CPU=$ALGO_CPU
XMRIG_UNIX_BIN=$XMRIG_UNIX_BIN
XMRIG_THREADS=$XMRIG_THREADS
XMRIG_CPU_PRIORITY=$XMRIG_CPU_PRIORITY
XMRIG_CPU_AFFINITY=$XMRIG_CPU_AFFINITY
XMRIG_PRINT_TIME=$XMRIG_PRINT_TIME
XMRIG_HEALTH_PRINT_TIME=$XMRIG_HEALTH_PRINT_TIME
XMRIG_DONATE_LEVEL=$XMRIG_DONATE_LEVEL
XMRIG_HUGE_PAGES_JIT=$XMRIG_HUGE_PAGES_JIT

POOL_GPU=$POOL_GPU
ALGO_GPU=$ALGO_GPU
LOLMINER_UNIX_BIN=$LOLMINER_UNIX_BIN
LOL_WORKER_NAME=$LOL_WORKER_NAME
LOL_API_PORT=$LOL_API_PORT
LOL_EXTRA_ARGS=$LOL_EXTRA_ARGS
EOF
}

save_profile_config() {
  mkdir -p "$PROFILE_DIR"
  cat > "$PROFILE_DIR/$PROFILE_NAME.env" <<EOF
COIN=$COIN
WALLET=$WALLET
PASSWORD=$PASSWORD
WORKER_NAME=$WORKER_NAME
RIG_ID=$RIG_ID
AUTOSTART_PROFILE=$AUTOSTART_PROFILE
POOL_CPU=$POOL_CPU
ALGO_CPU=$ALGO_CPU
XMRIG_THREADS=$XMRIG_THREADS
XMRIG_CPU_PRIORITY=$XMRIG_CPU_PRIORITY
XMRIG_CPU_AFFINITY=$XMRIG_CPU_AFFINITY
XMRIG_PRINT_TIME=$XMRIG_PRINT_TIME
XMRIG_HEALTH_PRINT_TIME=$XMRIG_HEALTH_PRINT_TIME
XMRIG_DONATE_LEVEL=$XMRIG_DONATE_LEVEL
XMRIG_HUGE_PAGES_JIT=$XMRIG_HUGE_PAGES_JIT
POOL_GPU=$POOL_GPU
ALGO_GPU=$ALGO_GPU
LOL_WORKER_NAME=$LOL_WORKER_NAME
LOL_API_PORT=$LOL_API_PORT
LOL_EXTRA_ARGS=$LOL_EXTRA_ARGS
EOF
}

load_profile_config() {
  local selected_profile="$1"
  local profile_file="$PROFILE_DIR/$selected_profile.env"
  [[ -f "$profile_file" ]] || return 1
  PROFILE_NAME="$selected_profile"
  RUN_MODE="profile"
  load_env_file "$profile_file"
  save_config
}

list_profiles() {
  mkdir -p "$PROFILE_DIR"
  find "$PROFILE_DIR" -maxdepth 1 -type f -name '*.env' -exec basename {} .env \; | sort
}

show_current_config() {
  local total_cpu
  total_cpu=$(detect_logical_cpu)
  clear_screen
  panel_title "MINING CONTROL CENTER"
  printf "%sPortable desktop miner setup%s\n" "$C_DIM" "$C_RESET"
  hr
  panel_title "System"
  status_line "OS" "$UNAME_S" "$C_VALUE"
  status_line "Logical CPU" "$total_cpu" "$C_VALUE"
  status_line "Autostart" "$(autostart_status)" "$C_VALUE"
  hr
  panel_title "Profile"
  status_line "Coin" "$COIN" "$C_VALUE"
  status_line "Wallet" "$WALLET" "$C_VALUE"
  status_line "Worker" "$WORKER_NAME" "$C_VALUE"
  status_line "Default mode" "$AUTOSTART_PROFILE" "$C_HOT"
  status_line "Run mode" "$RUN_MODE" "$C_HOT"
  status_line "Active profile" "$PROFILE_NAME" "$C_VALUE"
  status_line "CPU pool" "$POOL_CPU" "$C_VALUE"
  status_line "CPU threads" "$XMRIG_THREADS" "$C_HOT"
  status_line "GPU pool" "$POOL_GPU" "$C_VALUE"
  hr
  panel_title "Tools"
  status_line "XMRig" "$(binary_status "$XMRIG_UNIX_BIN")  $XMRIG_UNIX_BIN" "$C_VALUE"
  status_line "lolMiner" "$(binary_status "$LOLMINER_UNIX_BIN")  $LOLMINER_UNIX_BIN" "$C_VALUE"
  status_line "Config file" "$ENV_FILE" "$C_VALUE"
  hr
}

setup_profile() {
  local total_cpu cpu_percent percent_default mode_choice
  total_cpu=$(detect_logical_cpu)
  panel_title "Setup Wizard"
  printf "%sIsi kosong untuk pakai nilai lama.%s\n" "$C_DIM" "$C_RESET"
  COIN=$(prompt_default "Coin payout" "$COIN")
  WALLET=$(prompt_default "Wallet" "$WALLET")
  WORKER_NAME=$(prompt_default "Worker name" "$WORKER_NAME")
  LOL_WORKER_NAME="$WORKER_NAME"
  RIG_ID=$(prompt_default "Rig ID (opsional)" "$RIG_ID")
  choose_option "Pilih mode XMRig" "profile" "cli"
  RUN_MODE="$CHOOSE_RESULT"
  mode_choice=$(choose_option "Pilih default mode" "cpu" "gpu" "both")
  AUTOSTART_PROFILE="$mode_choice"
  POOL_CPU=$(prompt_default "CPU pool" "$POOL_CPU")
  POOL_GPU=$(prompt_default "GPU pool" "$POOL_GPU")
  percent_default=$((XMRIG_THREADS * 100 / total_cpu))
  cpu_percent=$(prompt_default "Pakai CPU berapa persen (1-100)" "$percent_default")
  XMRIG_THREADS=$(calc_threads_from_percent "$cpu_percent")
  XMRIG_CPU_PRIORITY=$(prompt_default "CPU priority" "$XMRIG_CPU_PRIORITY")
  XMRIG_CPU_AFFINITY=$(prompt_default "CPU affinity hex (opsional)" "$XMRIG_CPU_AFFINITY")
  if [[ "$RUN_MODE" == "cli" ]]; then
    XMRIG_CLI_ARGS=$(prompt_default "XMRig CLI args" "$XMRIG_CLI_ARGS")
  else
    PROFILE_NAME=$(prompt_default "Nama profile" "$PROFILE_NAME")
    XMRIG_CLI_ARGS=""
  fi
  XMRIG_UNIX_BIN=$(prompt_default "Path XMRig Unix" "$XMRIG_UNIX_BIN")
  LOLMINER_UNIX_BIN=$(prompt_default "Path lolMiner Unix" "$LOLMINER_UNIX_BIN")
  if [[ "$RUN_MODE" == "profile" ]]; then
    save_profile_config
  fi
  save_config
  printf "%sConfig tersimpan ke%s %s%s%s\n" "$C_OK" "$C_RESET" "$C_VALUE" "$ENV_FILE" "$C_RESET"
}

select_saved_profile() {
  local profiles profile_options=()
  while IFS= read -r p; do
    [[ -n "$p" ]] && profile_options+=("$p")
  done <<EOF
$(list_profiles)
EOF

  if [[ ${#profile_options[@]} -eq 0 ]]; then
    printf "%sBelum ada profile tersimpan.%s\n" "$C_WARN" "$C_RESET"
    return
  fi

  choose_option "Pilih profile tersimpan" "${profile_options[@]}"
  load_profile_config "$CHOOSE_RESULT"
  printf "%sProfile aktif:%s %s%s%s\n" "$C_OK" "$C_RESET" "$C_VALUE" "$CHOOSE_RESULT" "$C_RESET"
}

run_profile_now() {
  choose_option "Pilih mode mining sekarang" "cpu" "gpu" "both"
  exec "$SCRIPT_DIR/start-profile.sh" "$CHOOSE_RESULT"
}

toggle_autostart() {
  local action
  local enable_script disable_script
  if [[ "$UNAME_S" == "Darwin" ]]; then
    enable_script="$ROOT/scripts/macos/enable-autostart.sh"
    disable_script="$ROOT/scripts/macos/disable-autostart.sh"
  else
    enable_script="$ROOT/scripts/linux/enable-autostart.sh"
    disable_script="$ROOT/scripts/linux/disable-autostart.sh"
  fi

  choose_option "Autostart" "Aktifkan autostart" "Matikan autostart" "Kembali"
  case "$CHOOSE_RESULT" in
    "Aktifkan autostart")
      "$enable_script"
      ;;
    "Matikan autostart")
      "$disable_script"
      ;;
    *)
      return
      ;;
  esac
}

update_xmrig_now() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    "$ROOT/scripts/macos/update-xmrig.sh"
  else
    "$ROOT/scripts/linux/update-xmrig.sh"
  fi
}

pause_to_dashboard() {
  if [[ -t 0 && -t 1 ]]; then
    printf "\n%sTekan Enter untuk kembali ke dashboard...%s" "$C_DIM" "$C_RESET"
    IFS= read -r _pause
  fi
}

main_menu() {
  choose_option "Menu Utama" \
    "Setup / ubah config" \
    "Pilih profile tersimpan" \
    "Jalankan mining sekarang" \
    "Update XMRig" \
    "Autostart on/off" \
    "Keluar"
}

while true; do
  show_current_config
  main_menu
  case "$CHOOSE_RESULT" in
    "Setup / ubah config")
      setup_profile
      ;;
    "Pilih profile tersimpan")
      select_saved_profile
      ;;
    "Jalankan mining sekarang")
      run_profile_now
      ;;
    "Update XMRig")
      update_xmrig_now
      ;;
    "Autostart on/off")
      toggle_autostart
      ;;
    "Keluar")
      exit 0
      ;;
  esac
  pause_to_dashboard
done
