#!/usr/bin/env bash
# utils.sh — clipboard, password generation, OS detection, logging

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        case "${ID:-}" in
          fedora)           echo "fedora" ;;
          opensuse*|sles)   echo "opensuse" ;;
          ubuntu|debian)    echo "debian" ;;
          arch|manjaro)     echo "arch" ;;
          *)                echo "linux" ;;
        esac
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

copy_to_clipboard() {
  local text="$1"
  case "$(uname -s)" in
    Darwin)
      printf '%s' "$text" | pbcopy
      ;;
    *)
      if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy &>/dev/null; then
        printf '%s' "$text" | wl-copy
      elif [[ -n "${DISPLAY:-}" ]] && command -v xclip &>/dev/null; then
        printf '%s' "$text" | xclip -selection clipboard
      elif [[ -n "${DISPLAY:-}" ]] && command -v xsel &>/dev/null; then
        printf '%s' "$text" | xsel --clipboard --input
      else
        log_error "No clipboard tool available (install xclip or wl-clipboard)"
        return 1
      fi
      ;;
  esac
}

generate_password() {
  local length="${1:-20}"
  # Use /dev/urandom for cryptographic randomness
  local chars='A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?'
  local pw
  pw="$(LC_ALL=C tr -dc "$chars" </dev/urandom | head -c "$length")"
  echo "$pw"
}

log_info()  { printf '\033[0;32m[INFO]\033[0m  %s\n' "$*" >&2; }
log_warn()  { printf '\033[0;33m[WARN]\033[0m  %s\n' "$*" >&2; }
log_error() { printf '\033[0;31m[ERROR]\033[0m %s\n' "$*" >&2; }

# Secure temp file — auto-cleaned on EXIT
make_temp_file() {
  local tmp
  tmp="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" EXIT
  echo "$tmp"
}

# Single-keypress Y/N prompt; default is first arg (Y or N)
confirm() {
  local prompt="${1:-Continue?} [Y/n] "
  local reply
  read -r -n1 -p "$prompt" reply
  echo
  [[ "${reply,,}" != "n" ]]
}
