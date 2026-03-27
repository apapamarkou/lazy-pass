#!/usr/bin/env bash
# lib/preview-field.sh — fzf preview: show current value of a field
# Usage: preview-field.sh <field> <password> <username> <url> <email> <otp> <notes>
set -euo pipefail

field="$1"
# $2 = password (masked, not used in output)
username="$3"
url="$4"
email="$5"
otp="$6"
notes="$7"

case "$field" in
  password) echo "password : ******" ;;
  username) printf 'username : %s\n' "$username" ;;
  url)      printf 'url      : %s\n' "$url" ;;
  email)    printf 'email    : %s\n' "$email" ;;
  otp)      printf 'otp      : %s\n' "$otp" ;;
  notes)    printf 'notes    : %s\n' "$notes" ;;
esac
