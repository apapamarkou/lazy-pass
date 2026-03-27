#!/usr/bin/env bash
# backend.sh — pass wrapper: list, show, insert, delete, parse

# List all pass entries as full paths (e.g. mail/gmail/user@example.com)
backend_list() {
  local store="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
  find "$store" -name '*.gpg' 2>/dev/null \
    | sed "s|${store}/||;s|\.gpg$||" \
    | sort
}

# Warm the GPG agent cache by decrypting one entry in the foreground terminal.
# This ensures fzf subshells (preview, binds) can decrypt without a TTY.
backend_warm_cache() {
  local store="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
  local first
  first="$(find "$store" -name '*.gpg' 2>/dev/null | head -n1)"
  [[ -z "$first" ]] && return 0
  local name
  name="$(printf '%s' "$first" | sed "s|${store}/||;s|\.gpg$||")"
  # Decrypt once on the real TTY so gpg-agent caches the passphrase
  pass show "$name" >/dev/null
}

# Show raw decrypted content of an entry
backend_show() {
  local name="$1"
  pass show "$name" 2>/dev/null
}

# Parse a specific field from entry content
# Usage: backend_parse_field <content> <field>
# field: password | username | url | email | otp | notes
backend_parse_field() {
  local content="$1"
  local field="$2"
  case "$field" in
    password) echo "$content" | head -n1 ;;
    *)        echo "$content" | grep -i "^${field}:" | head -n1 | cut -d' ' -f2- ;;
  esac
}

# Build entry content string from parts
backend_build_entry() {
  local password="$1" username="$2" url="$3" email="$4" otp="$5" notes="$6"
  printf '%s\nusername: %s\nurl: %s\nemail: %s\notp: %s\nnotes: %s\n' \
    "$password" "$username" "$url" "$email" "$otp" "$notes"
}

# Insert or update an entry (multiline via stdin)
backend_insert() {
  local name="$1"
  local content="$2"
  # --force overwrites existing; --multiline preserves newlines
  printf '%s' "$content" | pass insert --force --multiline "$name" &>/dev/null
}

# Delete an entry
backend_delete() {
  local name="$1"
  pass rm --force "$name" &>/dev/null
}

# Check if pass store is initialized
backend_is_initialized() {
  pass ls &>/dev/null
}
