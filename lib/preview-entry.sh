#!/usr/bin/env bash
# lib/preview-entry.sh — fzf preview: show entry fields, mask password
set -euo pipefail

# shellcheck source=backend.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
# shellcheck source=backend.sh
source "$(dirname "${BASH_SOURCE[0]}")/backend.sh"

name="$1"
content="$(backend_show "$name")" || { echo "(unable to decrypt)"; exit 0; }

pw="$(backend_parse_field "$content" password)"
username="$(backend_parse_field "$content" username)"
url="$(backend_parse_field "$content" url)"
email="$(backend_parse_field "$content" email)"
otp="$(backend_parse_field "$content" otp)"
notes="$(backend_parse_field "$content" notes)"

printf 'password : ******\nusername : %s\nurl      : %s\nemail    : %s\notp      : %s\nnotes    : %s\n' \
  "$username" "$url" "$email" "$otp" "$notes"

# pw is intentionally masked; reference it to satisfy shellcheck
: "$pw"
