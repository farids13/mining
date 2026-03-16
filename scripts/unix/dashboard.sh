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

init_colors() {
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
}

init_colors

hr() {
  printf "%s────────────────────────────────────────────────────────%s\n" "$C_PANEL" "$C_RESET"
}

short_text() {
  local text="$1"
  local max_len="${2:-42}"
  local text_len=${#text}
  if (( text_len <= max_len )); then
    printf '%s' "$text"
    return
  fi
  printf '%s...%s' "${text:0:18}" "${text:text_len-18}"
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

show_menu_frame() {
  local title="$1"
  shift
  local options=("$@")
  local selected="${CHOOSE_INDEX:-0}"

  show_current_config
  panel_title "$title"
  printf "%sGunakan panah atas/bawah lalu Enter untuk memilih.%s\n" "$C_DIM" "$C_RESET"
  hr

  local i
  for i in "${!options[@]}"; do
    if [[ "$i" -eq "$selected" ]]; then
      printf "%b> %s%b\n" "$C_SELECT" "${options[$i]}" "$C_RESET"
    else
      printf "  %s\n" "${options[$i]}"
    fi
  done
  hr
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
  if is_service_configured; then
    printf '%bconfigured%b' "$C_OK" "$C_RESET"
  else
    printf '%boff%b' "$C_WARN" "$C_RESET"
  fi
}

service_name() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    printf '%s\n' "com.fast.mining-portable"
  else
    printf '%s\n' "mining-portable.service"
  fi
}

service_config_path() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    printf '%s\n' "$HOME/Library/LaunchAgents/com.fast.mining-portable.plist"
  else
    printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/mining-portable.service"
  fi
}

is_service_configured() {
  [[ -f "$(service_config_path)" ]]
}

service_running() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    launchctl print "gui/$(id -u)/com.fast.mining-portable" >/dev/null 2>&1
  else
    systemctl --user is-active --quiet mining-portable.service
  fi
}

miner_running() {
  pgrep -f "$XMRIG_UNIX_BIN|$LOLMINER_UNIX_BIN" >/dev/null 2>&1
}

miner_status() {
  if service_running; then
    printf '%brunning via autostart%b' "$C_OK" "$C_RESET"
  elif miner_running; then
    printf '%brunning manually%b' "$C_OK" "$C_RESET"
  else
    printf '%boff%b' "$C_WARN" "$C_RESET"
  fi
}

detect_logical_cpu() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    sysctl -n hw.logicalcpu 2>/dev/null || echo 4
  else
    getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4
  fi
}

detect_physical_cpu() {
  if [[ "$UNAME_S" == "Darwin" ]]; then
    sysctl -n hw.physicalcpu 2>/dev/null || detect_logical_cpu
  else
    lscpu 2>/dev/null | awk -F: '/^Core\\(s\\) per socket:/ {gsub(/^[ \t]+/, "", $2); cores=$2} /^Socket\\(s\\):/ {gsub(/^[ \t]+/, "", $2); sockets=$2} END {if (cores > 0 && sockets > 0) print cores * sockets}'
  fi
}

cpu_mask_from_list() {
  local cpu_list="$1"
  local mask=0
  local cpu
  for cpu in $cpu_list; do
    if [[ "$cpu" =~ ^[0-9]+$ ]] && (( cpu < 63 )); then
      mask=$((mask | (1 << cpu)))
    fi
  done
  printf '0x%X\n' "$mask"
}

build_core_groups() {
  CORE_GROUP_LABELS=()
  CORE_GROUP_MASKS=()
  CORE_GROUP_THREADS=()

  if [[ "$UNAME_S" != "Darwin" ]] && command -v lscpu >/dev/null 2>&1; then
    local raw_line core_id cpu_id cpu_list thread_count mask
    local -A core_cpu_map=()
    local -a core_order=()

    while IFS=, read -r core_id cpu_id; do
      [[ -z "$core_id" || -z "$cpu_id" ]] && continue
      if [[ -z "${core_cpu_map[$core_id]+x}" ]]; then
        core_order+=("$core_id")
        core_cpu_map[$core_id]="$cpu_id"
      else
        core_cpu_map[$core_id]="${core_cpu_map[$core_id]} $cpu_id"
      fi
    done < <(lscpu -p=CORE,CPU 2>/dev/null | grep -v '^#')

    if (( ${#core_order[@]} > 0 )); then
      local index=1
      for core_id in "${core_order[@]}"; do
        cpu_list="${core_cpu_map[$core_id]}"
        thread_count=$(wc -w <<< "$cpu_list")
        mask=$(cpu_mask_from_list "$cpu_list")
        CORE_GROUP_LABELS+=("Core $index (~$thread_count thread, $mask)")
        CORE_GROUP_MASKS+=("$mask")
        CORE_GROUP_THREADS+=("$thread_count")
        index=$((index + 1))
      done
      return
    fi
  fi

  local logical_cpu physical_cpu threads_per_core cpu_index core_index cpu_list thread_count mask
  logical_cpu=$(detect_logical_cpu)
  physical_cpu=$(detect_physical_cpu)
  if ! [[ "$physical_cpu" =~ ^[0-9]+$ ]] || (( physical_cpu < 1 )); then
    physical_cpu="$logical_cpu"
  fi
  threads_per_core=$((logical_cpu / physical_cpu))
  if (( threads_per_core < 1 )); then
    threads_per_core=1
  fi

  cpu_index=0
  for ((core_index = 1; core_index <= physical_cpu && cpu_index < logical_cpu; core_index++)); do
    cpu_list=""
    thread_count=0
    while (( thread_count < threads_per_core && cpu_index < logical_cpu )); do
      cpu_list="$cpu_list $cpu_index"
      cpu_index=$((cpu_index + 1))
      thread_count=$((thread_count + 1))
    done
    cpu_list="${cpu_list# }"
    mask=$(cpu_mask_from_list "$cpu_list")
    CORE_GROUP_LABELS+=("Core $core_index (~$thread_count thread, $mask)")
    CORE_GROUP_MASKS+=("$mask")
    CORE_GROUP_THREADS+=("$thread_count")
  done
}

build_core_limit_options() {
  local i
  CORE_LIMIT_OPTIONS=("Auto / semua core")
  for ((i = 0; i < ${#CORE_GROUP_LABELS[@]}; i++)); do
    CORE_LIMIT_OPTIONS+=("Pakai $((i + 1)) core pertama - ${CORE_GROUP_LABELS[$i]}")
  done
}

apply_core_limit() {
  local selected_count="$1"
  local combined_mask=0
  local allowed_threads=0
  local i

  if ! [[ "$selected_count" =~ ^[0-9]+$ ]] || (( selected_count <= 0 )); then
    XMRIG_CPU_AFFINITY=""
    return
  fi

  build_core_groups
  for ((i = 0; i < selected_count && i < ${#CORE_GROUP_MASKS[@]}; i++)); do
    combined_mask=$((combined_mask | ${CORE_GROUP_MASKS[$i]}))
    allowed_threads=$((allowed_threads + ${CORE_GROUP_THREADS[$i]}))
  done

  XMRIG_CPU_AFFINITY=$(printf '0x%X' "$combined_mask")
  if (( XMRIG_THREADS > allowed_threads )); then
    XMRIG_THREADS="$allowed_threads"
  fi
}

save_global_config() {
  cat > "$GLOBAL_ENV_FILE" <<EOF
COIN=$COIN
WALLET=$WALLET
PASSWORD=$PASSWORD
AUTOSTART_PROFILE=$AUTOSTART_PROFILE
RUN_MODE=$RUN_MODE
PROFILE_NAME=$PROFILE_NAME
XMRIG_CLI_ARGS=$XMRIG_CLI_ARGS

POOL_CPU=$POOL_CPU
ALGO_CPU=$ALGO_CPU
XMRIG_THREADS=$XMRIG_THREADS
XMRIG_CPU_PRIORITY=$XMRIG_CPU_PRIORITY
XMRIG_PRINT_TIME=$XMRIG_PRINT_TIME
XMRIG_HEALTH_PRINT_TIME=$XMRIG_HEALTH_PRINT_TIME
XMRIG_DONATE_LEVEL=$XMRIG_DONATE_LEVEL
XMRIG_HUGE_PAGES_JIT=$XMRIG_HUGE_PAGES_JIT

POOL_GPU=$POOL_GPU
ALGO_GPU=$ALGO_GPU
LOL_API_PORT=$LOL_API_PORT
LOL_EXTRA_ARGS=$LOL_EXTRA_ARGS
EOF
}

save_local_config() {
  cat > "$ENV_FILE" <<EOF
WORKER_NAME=$WORKER_NAME
LOL_WORKER_NAME=$LOL_WORKER_NAME
RIG_ID=$RIG_ID
XMRIG_UNIX_BIN=$XMRIG_UNIX_BIN
XMRIG_CPU_AFFINITY=$XMRIG_CPU_AFFINITY
LOLMINER_UNIX_BIN=$LOLMINER_UNIX_BIN
EOF
}

save_profile_env() {
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

collect_profile_options() {
  local profile_options=()
  local p
  while IFS= read -r p; do
    [[ -n "$p" ]] && profile_options+=("$p")
  done <<EOF
$(list_profiles)
EOF
  if (( ${#profile_options[@]} > 0 )); then
    printf '%s\n' "${profile_options[@]}"
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

detect_cpu_power_mode() {
  local total_cpu current_threads
  total_cpu=$(detect_logical_cpu)
  current_threads="${XMRIG_THREADS:-1}"
  if (( current_threads >= total_cpu )); then
    printf '%s\n' "full"
  elif (( current_threads * 2 >= total_cpu )); then
    printf '%s\n' "half"
  elif (( current_threads * 4 >= total_cpu )); then
    printf '%s\n' "quarter"
  else
    printf '%s\n' "custom"
  fi
}

apply_cpu_power_mode() {
  local mode="$1"
  local total_cpu
  total_cpu=$(detect_logical_cpu)
  case "$mode" in
    full)
      XMRIG_THREADS="$total_cpu"
      ;;
    half)
      XMRIG_THREADS=$((total_cpu / 2))
      if (( XMRIG_THREADS < 1 )); then XMRIG_THREADS=1; fi
      ;;
    quarter)
      XMRIG_THREADS=$((total_cpu / 4))
      if (( XMRIG_THREADS < 1 )); then XMRIG_THREADS=1; fi
      ;;
  esac
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
    CHOOSE_INDEX="$selected"
    show_menu_frame "$title" "${options[@]}"

    IFS= read -rsn1 key < /dev/tty
    if [[ "$key" == $'\x1b' ]]; then
      IFS= read -rsn2 key < /dev/tty || true
      case "$key" in
        '[A')
          selected=$((selected - 1))
          if (( selected < 0 )); then selected=$((${#options[@]} - 1)); fi
          ;;
        '[B')
          selected=$((selected + 1))
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
  mkdir -p "$ROOT/config"
  mkdir -p "$ROOT/config.local"
  save_global_config
  save_local_config
}

save_profile_config() {
  mkdir -p "$PROFILE_DIR"
  save_profile_env
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
  status_line "Wallet" "$(short_text "$WALLET" 26)" "$C_VALUE"
  status_line "Worker" "$WORKER_NAME" "$C_VALUE"
  status_line "Default mode" "$AUTOSTART_PROFILE" "$C_HOT"
  status_line "Run mode" "$RUN_MODE" "$C_HOT"
  status_line "Active profile" "$PROFILE_NAME" "$C_VALUE"
  status_line "CPU mode" "$(detect_cpu_power_mode)" "$C_HOT"
  status_line "CPU pool" "$POOL_CPU" "$C_VALUE"
  status_line "CPU threads" "$XMRIG_THREADS" "$C_HOT"
  status_line "CPU priority" "$XMRIG_CPU_PRIORITY" "$C_HOT"
  status_line "CPU affinity" "${XMRIG_CPU_AFFINITY:-auto}" "$C_HOT"
  status_line "GPU pool" "$POOL_GPU" "$C_VALUE"
  hr
  panel_title "Tools"
  status_line "XMRig" "$(binary_status "$XMRIG_UNIX_BIN")  $(short_text "$XMRIG_UNIX_BIN" 36)" "$C_VALUE"
  status_line "lolMiner" "$(binary_status "$LOLMINER_UNIX_BIN")  $(short_text "$LOLMINER_UNIX_BIN" 36)" "$C_VALUE"
  status_line "Miner status" "$(miner_status)" "$C_VALUE"
  status_line "Config file" "$(short_text "$ENV_FILE" 38)" "$C_VALUE"
  hr
}

setup_profile() {
  local total_cpu cpu_percent percent_default cpu_power_mode
  local selected_core_count
  total_cpu=$(detect_logical_cpu)
  build_core_groups
  build_core_limit_options
  panel_title "Setup Wizard"
  printf "%sIsi kosong untuk pakai nilai lama.%s\n" "$C_DIM" "$C_RESET"
  COIN=$(prompt_default "Coin payout" "$COIN")
  WALLET=$(prompt_default "Wallet" "$WALLET")
  WORKER_NAME=$(prompt_default "Worker name" "$WORKER_NAME")
  LOL_WORKER_NAME="$WORKER_NAME"
  RIG_ID=$(prompt_default "Rig ID (opsional)" "${RIG_ID:-}")
  choose_option "Pilih mode XMRig" "profile" "cli"
  RUN_MODE="$CHOOSE_RESULT"
  choose_option "Pilih default mode" "cpu" "gpu" "both"
  AUTOSTART_PROFILE="$CHOOSE_RESULT"
  POOL_CPU=$(prompt_default "CPU pool" "$POOL_CPU")
  POOL_GPU=$(prompt_default "GPU pool" "$POOL_GPU")
  choose_option "Pilih tenaga CPU" "full" "half" "quarter" "custom"
  cpu_power_mode="$CHOOSE_RESULT"
  if [[ "$cpu_power_mode" == "custom" ]]; then
    percent_default=$((XMRIG_THREADS * 100 / total_cpu))
    cpu_percent=$(prompt_default "Pakai CPU berapa persen (1-100)" "$percent_default")
    XMRIG_THREADS=$(calc_threads_from_percent "$cpu_percent")
  else
    apply_cpu_power_mode "$cpu_power_mode"
  fi
  choose_option "Pilih CPU priority" "1" "2" "3" "4" "5"
  XMRIG_CPU_PRIORITY="$CHOOSE_RESULT"
  choose_option "Pilih batas core CPU" "${CORE_LIMIT_OPTIONS[@]}"
  if [[ "$CHOOSE_RESULT" == "Auto / semua core" ]]; then
    XMRIG_CPU_AFFINITY=""
  else
    selected_core_count=${CHOOSE_RESULT#Pakai }
    selected_core_count=${selected_core_count%% core pertama*}
    apply_core_limit "$selected_core_count"
  fi
  XMRIG_CPU_AFFINITY=$(prompt_default "CPU affinity hex (opsional)" "${XMRIG_CPU_AFFINITY:-}")
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
  printf "%sConfig global tersimpan ke%s %s%s%s\n" "$C_OK" "$C_RESET" "$C_VALUE" "$GLOBAL_ENV_FILE" "$C_RESET"
  printf "%sOverride lokal tersimpan ke%s %s%s%s\n" "$C_OK" "$C_RESET" "$C_VALUE" "$ENV_FILE" "$C_RESET"
}

select_saved_profile() {
  local profile_options=()
  local profile_name
  while IFS= read -r profile_name; do
    [[ -n "$profile_name" ]] && profile_options+=("$profile_name")
  done <<EOF
$(collect_profile_options)
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

show_running_miners() {
  local processes
  processes=$(pgrep -af "$XMRIG_UNIX_BIN|$LOLMINER_UNIX_BIN" || true)
  if [[ -n "$processes" ]]; then
    printf "%sProses miner aktif:%s\n" "$C_OK" "$C_RESET"
    printf "%s\n" "$processes"
  else
    printf "%sTidak ada proses miner yang sedang jalan.%s\n" "$C_WARN" "$C_RESET"
  fi
}

latest_xmrig_log_line() {
  local pattern="$1"
  if [[ "$UNAME_S" == "Darwin" ]]; then
    return 1
  fi
  journalctl --user -u mining-portable.service -n 300 --no-pager 2>/dev/null | grep -E "$pattern" | tail -n 1
}

show_xmrig_stats() {
  local hashrate_line results_line
  clear_screen
  panel_title "XMRig Stats"
  hr

  if ! service_running; then
    show_running_miners
    printf "\n"
    if miner_running; then
      printf "%sMiner berjalan manual.%s Hashrate dan results detail tersedia di terminal asal proses itu dijalankan.\n" "$C_WARN" "$C_RESET"
    else
      printf "%sTidak ada miner yang sedang jalan.%s\n" "$C_WARN" "$C_RESET"
    fi
    return
  fi

  if [[ "$UNAME_S" == "Darwin" ]]; then
    printf "%sRingkasan hashrate/results otomatis belum saya aktifkan untuk macOS.%s Gunakan menu log mining untuk lihat output live.\n" "$C_WARN" "$C_RESET"
    return
  fi

  hashrate_line=$(latest_xmrig_log_line "speed 10s/60s/15m|miner[[:space:]]+speed")
  results_line=$(latest_xmrig_log_line "results:|accepted \\(|rejected \\(|invalid \\(")

  if [[ -n "$hashrate_line" ]]; then
    printf "%sHashrate terakhir:%s\n%s\n\n" "$C_OK" "$C_RESET" "$hashrate_line"
  else
    printf "%sHashrate terakhir belum ditemukan di log.%s Tunggu sampai XMRig mencetak statistik periodik.\n\n" "$C_WARN" "$C_RESET"
  fi

  if [[ -n "$results_line" ]]; then
    printf "%sResults terakhir:%s\n%s\n" "$C_OK" "$C_RESET" "$results_line"
  else
    printf "%sResults terakhir belum ditemukan di log.%s Tunggu sampai ada accepted/rejected share.\n" "$C_WARN" "$C_RESET"
  fi
}

show_mining_logs() {
  clear_screen
  panel_title "Mining Logs"
  hr

  if service_running; then
    printf "%sService aktif:%s %s%s%s\n" "$C_OK" "$C_RESET" "$C_VALUE" "$(service_name)" "$C_RESET"
    printf "%sTekan Ctrl+C untuk keluar dari log live.%s\n\n" "$C_DIM" "$C_RESET"
    if [[ "$UNAME_S" == "Darwin" ]]; then
      log stream --style compact --predicate 'process == "xmrig" || process == "lolMiner"' || true
    else
      journalctl --user -u mining-portable.service -f
    fi
    return
  fi

  show_running_miners
  printf "\n"
  if miner_running; then
    printf "%sMiner berjalan manual.%s Log live hanya tersedia di terminal asal proses itu dijalankan.\n" "$C_WARN" "$C_RESET"
  elif is_service_configured; then
    printf "%sAutostart terpasang tetapi servicenya sedang tidak aktif.%s\n" "$C_WARN" "$C_RESET"
  else
    printf "%sAutostart belum aktif dan tidak ada proses miner aktif.%s\n" "$C_WARN" "$C_RESET"
  fi
}

restart_autostart_mining() {
  clear_screen
  panel_title "Restart Autostart Mining"
  hr

  if ! is_service_configured; then
    printf "%sAutostart belum dikonfigurasi.%s Tidak ada mining autostart yang bisa direstart.\n" "$C_WARN" "$C_RESET"
    return
  fi

  if ! service_running; then
    if miner_running; then
      printf "%sAutostart terpasang tetapi servicenya sedang tidak aktif.%s Miner yang terdeteksi tampaknya berjalan manual, jadi restart autostart dilewati.\n" "$C_WARN" "$C_RESET"
    else
      printf "%sTidak ada mining autostart yang sedang jalan.%s Restart dilewati.\n" "$C_WARN" "$C_RESET"
    fi
    return
  fi

  if [[ "$UNAME_S" == "Darwin" ]]; then
    launchctl kickstart -k "gui/$(id -u)/$(service_name)"
  else
    systemctl --user restart mining-portable.service
  fi

  printf "%sMining autostart berhasil direstart.%s\n" "$C_OK" "$C_RESET"
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
    "Lihat log mining" \
    "Lihat hashrate / results" \
    "Restart mining autostart" \
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
    "Lihat log mining")
      show_mining_logs
      ;;
    "Lihat hashrate / results")
      show_xmrig_stats
      ;;
    "Restart mining autostart")
      restart_autostart_mining
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
