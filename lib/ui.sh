#!/usr/bin/env bash
# ui.sh — fzf-based UI: main screen, new entry, edit entry
# Requires: LAZY_PASS_LIB exported by bin/pass-ui

_fzf_base() {
  fzf --layout=reverse \
    --ansi \
    --no-mouse \
    "$@"
}

# ── main screen ───────────────────────────────────────────────────────────────

ui_main() {
  local subtitle='^N New  ^Q/ESC Quit  ^U URL  ^B Username  ^P Password  [ENTER] Edit'
  local preview_cmd="bash ${LAZY_PASS_LIB}/preview-entry.sh {}"
  local new_cmd="bash ${LAZY_PASS_LIB}/ui.sh --new-entry"
  local reload_cmd="bash -c 'source \"${LAZY_PASS_LIB}/utils.sh\"; source \"${LAZY_PASS_LIB}/backend.sh\"; backend_list'"

  while true; do
    local entries
    entries="$(backend_list)" || true

    local selection
    selection="$(
      echo "$entries" |
        _fzf_base \
          --header-first \
          --header="$(printf 'Passwords\n%s' "$subtitle")" \
          --preview="$preview_cmd" \
          --preview-window='right:40%:wrap' \
          --bind="ctrl-n:execute($new_cmd </dev/tty >/dev/tty 2>&1)+reload($reload_cmd)" \
          --bind='ctrl-q:abort' \
          --bind='esc:abort' \
          --bind="ctrl-u:execute(bash ${LAZY_PASS_LIB}/copy-field.sh {} url >/dev/null)" \
          --bind="ctrl-b:execute(bash ${LAZY_PASS_LIB}/copy-field.sh {} username >/dev/null)" \
          --bind="ctrl-p:execute(bash ${LAZY_PASS_LIB}/copy-field.sh {} password >/dev/null)" \
          --expect='enter' \
          2>/dev/null
    )" || return 0

    local key entry
    key="$(echo "$selection" | head -n1)"
    entry="$(echo "$selection" | tail -n1)"

    [[ -z "$entry" ]] && continue
    [[ "$key" == "enter" ]] && ui_edit_entry "$entry"
  done
}

# ── new entry ─────────────────────────────────────────────────────────────────

ui_new_entry() {
  local name password username url email otp notes autogen err

  while true; do
    read -re -p "Entry name: " name
    [[ -n "$name" ]] && break
    echo "Name is required."
  done

  read -r -n1 -p "Auto-generate password? [Y/n] " autogen
  echo
  if [[ "${autogen,,}" != "n" ]]; then
    password="$(generate_password 20)"
    echo "Generated password: $password"
  else
    while true; do
      read -res -p "Password: " password
      echo
      err="$(validate_password "$password" 2>&1)" && break
      echo "$err"
    done
  fi

  while true; do
    read -re -p "Username: " username
    err="$(validate_username "$username" 2>&1)" && break
    echo "$err"
  done

  while true; do
    read -re -p "URL (optional): " url
    err="$(validate_url "$url" 2>&1)" && break
    echo "$err"
  done

  read -re -p "Email (optional): " email

  while true; do
    read -re -p "OTP secret (optional): " otp
    err="$(validate_otp "$otp" 2>&1)" && break
    echo "$err"
  done

  read -re -p "Notes (optional): " notes

  echo
  printf 'Entry   : %s\nUsername: %s\nURL     : %s\nEmail   : %s\nOTP     : %s\nNotes   : %s\n' \
    "$name" "$username" "$url" "$email" "$otp" "$notes"
  read -r -n1 -p "Save? [Y/n] " confirm_save
  echo
  [[ "${confirm_save,,}" == "n" ]] && {
    echo "Aborted."
    return
  }

  local content
  content="$(backend_build_entry "$password" "$username" "$url" "$email" "$otp" "$notes")"
  backend_insert "$name" "$content" && echo "Saved '$name'." || echo "Failed to save."
}

# ── edit entry ────────────────────────────────────────────────────────────────

ui_edit_entry() {
  local name="$1"
  local content
  content="$(backend_show "$name")" || {
    log_error "Cannot decrypt '$name'"
    return 1
  }

  local pw username url email otp notes err
  pw="$(backend_parse_field "$content" password)"
  username="$(backend_parse_field "$content" username)"
  url="$(backend_parse_field "$content" url)"
  email="$(backend_parse_field "$content" email)"
  otp="$(backend_parse_field "$content" otp)"
  notes="$(backend_parse_field "$content" notes)"

  while true; do
    local field
    field="$(
      printf 'password\nusername\nurl\nemail\notp\nnotes' |
        _fzf_base \
          --header-first \
          --header="$(printf 'Edit: %s\n^Q/ESC to return' "$name")" \
          --preview="bash ${LAZY_PASS_LIB}/preview-field.sh {} $(printf '%q' "$pw") $(printf '%q' "$username") $(printf '%q' "$url") $(printf '%q' "$email") $(printf '%q' "$otp") $(printf '%q' "$notes")" \
          --bind='ctrl-q:abort' \
          --bind='esc:abort' \
          2>/dev/null
    )" || break

    clear
    case "$field" in
      password)
        printf 'password for %s:\n' "$name"
        read -r -n1 -p "Auto-generate? [Y/n] " ag
        echo
        if [[ "${ag,,}" != "n" ]]; then
          pw="$(generate_password 20)"
          echo "New password: $pw"
        else
          while true; do
            read -res -p "New password: " pw
            echo
            err="$(validate_password "$pw" 2>&1)" && break
            echo "$err"
          done
        fi
        ;;
      username)
        while true; do
          printf 'username for %s:\n' "$name"
          read -re -i "$username" -p "> " inp
          username="${inp:-$username}"
          err="$(validate_username "$username" 2>&1)" && break
          echo "$err"
        done
        ;;
      url)
        while true; do
          printf 'url for %s:\n' "$name"
          read -re -i "$url" -p "> " inp
          url="${inp:-$url}"
          err="$(validate_url "$url" 2>&1)" && break
          echo "$err"
        done
        ;;
      email)
        printf 'email for %s:\n' "$name"
        read -re -i "$email" -p "> " inp
        email="${inp:-$email}"
        ;;
      otp)
        while true; do
          printf 'otp for %s:\n' "$name"
          read -re -i "$otp" -p "> " inp
          otp="${inp:-$otp}"
          err="$(validate_otp "$otp" 2>&1)" && break
          echo "$err"
        done
        ;;
      notes)
        printf 'notes for %s:\n' "$name"
        read -re -i "$notes" -p "> " inp
        notes="${inp:-$notes}"
        ;;
    esac

    content="$(backend_build_entry "$pw" "$username" "$url" "$email" "$otp" "$notes")"
    backend_insert "$name" "$content" && echo "Saved." || echo "Failed to save."
  done
}

# ── CLI entry point (called by fzf ctrl-n subshell) ───────────────────────────

if [[ "${1:-}" == "--new-entry" ]]; then
  # shellcheck source=utils.sh
  source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
  # shellcheck source=validation.sh
  source "$(dirname "${BASH_SOURCE[0]}")/validation.sh"
  # shellcheck source=backend.sh
  source "$(dirname "${BASH_SOURCE[0]}")/backend.sh"
  ui_new_entry
fi
