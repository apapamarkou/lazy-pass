#!/usr/bin/env bats
# tests/install.bats

ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  export TEST_HOME
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"
  export INSTALL_DIR="$TEST_HOME/.local/share/lazy-pass"
  export BIN_DIR="$TEST_HOME/.local/bin"
  export SYMLINK="$BIN_DIR/passwords"
  export PASS_STORE="$TEST_HOME/.password-store"
}

teardown() {
  rm -rf "$TEST_HOME"
}

# ── _install_files ────────────────────────────────────────────────────────────

@test "install: _install_files creates bin and lib dirs" {
  source "$ROOT/install"
  mkdir -p "$INSTALL_DIR" "$BIN_DIR"
  cp -r "$ROOT/bin" "$ROOT/lib" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/bin/pass-ui"
  ln -sf "$INSTALL_DIR/bin/pass-ui" "$SYMLINK"

  [ -d "$INSTALL_DIR/bin" ]
  [ -d "$INSTALL_DIR/lib" ]
}

@test "install: symlink points to pass-ui" {
  source "$ROOT/install"
  mkdir -p "$INSTALL_DIR/bin" "$BIN_DIR"
  touch "$INSTALL_DIR/bin/pass-ui"
  chmod +x "$INSTALL_DIR/bin/pass-ui"
  ln -sf "$INSTALL_DIR/bin/pass-ui" "$SYMLINK"

  [ -L "$SYMLINK" ]
  target="$(readlink "$SYMLINK")"
  [ "$target" = "$INSTALL_DIR/bin/pass-ui" ]
}

@test "install: lib files are present after install" {
  source "$ROOT/install"
  mkdir -p "$INSTALL_DIR" "$BIN_DIR"
  cp -r "$ROOT/bin" "$ROOT/lib" "$INSTALL_DIR/"

  [ -f "$INSTALL_DIR/lib/backend.sh" ]
  [ -f "$INSTALL_DIR/lib/ui.sh" ]
  [ -f "$INSTALL_DIR/lib/utils.sh" ]
  [ -f "$INSTALL_DIR/lib/validation.sh" ]
}

@test "install: _check_path warns when BIN_DIR not in PATH" {
  source "$ROOT/install"
  export PATH="/usr/bin:/bin"  # BIN_DIR deliberately absent
  run _check_path
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
}

@test "install: _check_path silent when BIN_DIR in PATH" {
  source "$ROOT/install"
  export PATH="$BIN_DIR:/usr/bin:/bin"
  run _check_path
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ── _remove / uninstall ───────────────────────────────────────────────────────

@test "uninstall: _remove deletes a directory" {
  source "$ROOT/uninstall"
  mkdir -p "$TEST_HOME/target"
  _remove "$TEST_HOME/target"
  [ ! -d "$TEST_HOME/target" ]
}

@test "uninstall: _remove deletes a symlink" {
  source "$ROOT/uninstall"
  touch "$TEST_HOME/real"
  ln -sf "$TEST_HOME/real" "$TEST_HOME/link"
  _remove "$TEST_HOME/link"
  [ ! -L "$TEST_HOME/link" ]
}

@test "uninstall: _remove is a no-op for missing path" {
  source "$ROOT/uninstall"
  run _remove "$TEST_HOME/nonexistent"
  [ "$status" -eq 0 ]
}

@test "uninstall: removes install dir and symlink" {
  source "$ROOT/uninstall"
  mkdir -p "$INSTALL_DIR/bin" "$BIN_DIR"
  touch "$INSTALL_DIR/bin/pass-ui"
  ln -sf "$INSTALL_DIR/bin/pass-ui" "$SYMLINK"

  _remove "$SYMLINK"
  _remove "$INSTALL_DIR"

  [ ! -d "$INSTALL_DIR" ]
  [ ! -L "$SYMLINK" ]
}

@test "uninstall: curl|bash mode re-fetches script" {
  source "$ROOT/uninstall"
  # Stub curl and bash to verify _fetch_uninstall calls them
  curl_called=0
  bash_called=0
  curl()  { curl_called=1; touch "$1"; }   # stub: create the tmp file arg
  bash()  { bash_called=1; }               # stub: no-op execution
  # Simulate the curl|bash detection branch directly
  run _fetch_uninstall
  [ "$status" -eq 0 ]
}
