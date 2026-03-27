#!/usr/bin/env bash
# lib/copy-field.sh — copy a named field of an entry to clipboard
# Usage: copy-field.sh <entry-name> <field>
set -euo pipefail

# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
# shellcheck source=backend.sh
source "$(dirname "${BASH_SOURCE[0]}")/backend.sh"

name="$1"
field="$2"

content="$(backend_show "$name")" || { log_error "Cannot decrypt '$name'"; exit 1; }
value="$(backend_parse_field "$content" "$field")"
copy_to_clipboard "$value"
