#!/usr/bin/env bash
# test_helper.bash — shared setup for bats tests

# Isolate pass store to a temp directory
setup_pass_mock() {
  export PASSWORD_STORE_DIR
  PASSWORD_STORE_DIR="$(mktemp -d)"
  export GNUPGHOME
  GNUPGHOME="$(mktemp -d)"
}

teardown_pass_mock() {
  rm -rf "$PASSWORD_STORE_DIR" "$GNUPGHOME"
}

# Source all lib files
load_lib() {
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  # shellcheck source=../lib/utils.sh
  source "$root/lib/utils.sh"
  # shellcheck source=../lib/validation.sh
  source "$root/lib/validation.sh"
  # shellcheck source=../lib/backend.sh
  source "$root/lib/backend.sh"
}
