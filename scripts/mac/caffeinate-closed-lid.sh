#!/usr/bin/env bash
#
# Keep a MacBook awake with the lid closed.
#
# Plain `caffeinate` only blocks idle sleep. Closing the lid triggers a separate
# kernel sleep path that caffeinate cannot override. This script enables the
# pmset SleepDisabled flag (the only built-in knob for lid-close sleep) and runs
# caffeinate for additional idle/disk/display protection.
#
# Usage:
#   ./caffeinate-closed-lid.sh enable   # turn on closed-lid keep-awake
#   ./caffeinate-closed-lid.sh disable  # restore normal sleep behavior
#   ./caffeinate-closed-lid.sh status   # show current power/sleep state
#   ./caffeinate-closed-lid.sh install  # install LaunchAgent (survives reboot)
#   ./caffeinate-closed-lid.sh uninstall
#
set -euo pipefail

LABEL="com.user.caffeinate-closed-lid"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_SRC="${SCRIPT_DIR}/${LABEL}.plist"
PLIST_DST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs/caffeinate-closed-lid"

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "error: this script only runs on macOS" >&2
    exit 1
  fi
}

require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    echo "Administrator password required to change sleep settings."
    sudo -v
  fi
}

sleep_disabled_value() {
  pmset -g custom 2>/dev/null | awk -F': ' '/sleepdisabled/ {print tolower($2); exit}'
}

caffeinate_pid_file() {
  echo "${HOME}/.caffeinate-closed-lid.pid"
}

is_caffeinate_running() {
  local pid_file
  pid_file="$(caffeinate_pid_file)"
  if [[ -f "${pid_file}" ]]; then
    local pid
    pid="$(cat "${pid_file}")"
    if kill -0 "${pid}" 2>/dev/null; then
      return 0
    fi
    rm -f "${pid_file}"
  fi
  return 1
}

start_caffeinate() {
  if is_caffeinate_running; then
    echo "caffeinate already running (pid $(cat "$(caffeinate_pid_file)"))"
    return 0
  fi

  mkdir -p "${LOG_DIR}"
  nohup /usr/bin/caffeinate -dims \
    >> "${LOG_DIR}/caffeinate.log" 2>&1 &
  echo $! > "$(caffeinate_pid_file)"
  echo "started caffeinate -dims (pid $(cat "$(caffeinate_pid_file)"))"
}

stop_caffeinate() {
  local pid_file
  pid_file="$(caffeinate_pid_file)"
  if [[ -f "${pid_file}" ]]; then
    local pid
    pid="$(cat "${pid_file}")"
    if kill -0 "${pid}" 2>/dev/null; then
      kill "${pid}" 2>/dev/null || true
      echo "stopped caffeinate (pid ${pid})"
    fi
    rm -f "${pid_file}"
  fi

  # Also stop any launchd-managed instance.
  launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
}

enable_pmset() {
  require_sudo
  sudo pmset -a disablesleep 1
  sudo pmset -a sleep 0
  sudo pmset -a standby 0
  sudo pmset -a autopoweroff 0
  sudo pmset -a powernap 0
  sudo pmset -a tcpkeepalive 1
  echo "enabled pmset SleepDisabled and related keep-awake settings"
}

disable_pmset() {
  require_sudo
  sudo pmset -a disablesleep 0
  sudo pmset -a sleep 1
  sudo pmset -a standby 1
  sudo pmset -a autopoweroff 1
  sudo pmset -a powernap 1
  echo "restored default pmset sleep settings"
}

cmd_enable() {
  require_macos
  echo ""
  echo "Enabling closed-lid keep-awake."
  echo "Warning: a closed MacBook can overheat and drain battery quickly."
  echo "Run './caffeinate-closed-lid.sh disable' when finished."
  echo ""
  enable_pmset
  start_caffeinate
  cmd_status
}

cmd_disable() {
  require_macos
  stop_caffeinate
  disable_pmset
  cmd_status
}

cmd_status() {
  require_macos
  echo ""
  echo "=== SleepDisabled (lid-close sleep) ==="
  local disabled
  disabled="$(sleep_disabled_value)"
  if [[ "${disabled}" == "1" || "${disabled}" == "yes" ]]; then
    echo "  SleepDisabled: ON  (lid-close sleep is blocked)"
  else
    echo "  SleepDisabled: OFF (lid-close sleep is active)"
  fi

  echo ""
  echo "=== caffeinate process ==="
  if is_caffeinate_running; then
    echo "  running (pid $(cat "$(caffeinate_pid_file)"))"
  else
    echo "  not running"
  fi

  echo ""
  echo "=== LaunchAgent ==="
  if [[ -f "${PLIST_DST}" ]]; then
    echo "  installed at ${PLIST_DST}"
    launchctl print "gui/$(id -u)/${LABEL}" 2>/dev/null | grep -E 'state =|last exit code =' || true
  else
    echo "  not installed (run './caffeinate-closed-lid.sh install' for reboot persistence)"
  fi

  echo ""
  echo "=== Active sleep assertions ==="
  pmset -g assertions 2>/dev/null | head -20 || true
  echo ""
}

install_launch_agent() {
  require_macos
  mkdir -p "${HOME}/Library/LaunchAgents" "${LOG_DIR}"

  # Resolve the real path so launchd can find the script after install.
  local script_path
  script_path="$(cd "${SCRIPT_DIR}" && pwd)/caffeinate-closed-lid.sh"

  sed "s|__SCRIPT_PATH__|${script_path}|g; s|__LOG_DIR__|${LOG_DIR}|g" \
    "${PLIST_SRC}" > "${PLIST_DST}"

  launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "${PLIST_DST}"
  echo "installed LaunchAgent: ${PLIST_DST}"
}

cmd_install() {
  require_macos
  install_launch_agent
  cmd_enable
}

cmd_uninstall() {
  require_macos
  cmd_disable
  launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  rm -f "${PLIST_DST}"
  echo "removed LaunchAgent"
}

usage() {
  cat <<'EOF'
Keep a MacBook awake with the lid closed.

Commands:
  enable     Enable pmset SleepDisabled and start caffeinate -dims
  disable    Stop caffeinate and restore normal sleep settings
  status     Show current sleep/caffeinate state
  install    Install LaunchAgent and enable keep-awake (persists across reboot)
  uninstall  Disable keep-awake and remove LaunchAgent

Why pmset is required:
  caffeinate only prevents idle sleep. Closing the lid fires a separate kernel
  event that caffeinate cannot block. pmset disablesleep is the built-in flag
  that prevents sleep when the lid closes.

Safety:
  - Do not leave enabled unattended on battery.
  - Avoid storing a closed, awake MacBook in a bag (overheating risk).
  - Always run 'disable' when your task finishes.
EOF
}

main() {
  local cmd="${1:-}"
  case "${cmd}" in
    enable) cmd_enable ;;
    disable) cmd_disable ;;
    status) cmd_status ;;
    install) cmd_install ;;
    uninstall) cmd_uninstall ;;
    -h|--help|help|"") usage ;;
    *)
      echo "error: unknown command '${cmd}'" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
