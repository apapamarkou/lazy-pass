#!/usr/bin/env bats
# tests/backend.bats

load test_helper

setup() { load_lib; }

# ── backend_parse_field ───────────────────────────────────────────────────────

@test "parse_field: extracts password (first line)" {
  local content
  content="$(printf 'MyP@ssw0rd\nusername: alice\nurl: https://example.com\nemail: a@b.com\notp: \nnotes: test note')"
  run backend_parse_field "$content" password
  [ "$status" -eq 0 ]
  [ "$output" = "MyP@ssw0rd" ]
}

@test "parse_field: extracts username" {
  local content
  content="$(printf 'pass\nusername: alice\nurl: \nemail: \notp: \nnotes: ')"
  run backend_parse_field "$content" username
  [ "$output" = "alice" ]
}

@test "parse_field: extracts url" {
  local content
  content="$(printf 'pass\nusername: alice\nurl: https://example.com\nemail: \notp: \nnotes: ')"
  run backend_parse_field "$content" url
  [ "$output" = "https://example.com" ]
}

@test "parse_field: returns empty for missing field" {
  local content
  content="$(printf 'pass\nusername: alice\nurl: \nemail: \notp: \nnotes: ')"
  run backend_parse_field "$content" email
  [ "$output" = "" ]
}

# ── backend_build_entry ───────────────────────────────────────────────────────

@test "build_entry: produces correct format" {
  run backend_build_entry "P@ss1234" "alice" "https://x.com" "a@b.com" "JBSWY3DP" "my note"
  [ "$status" -eq 0 ]
  [[ "$output" == *"P@ss1234"* ]]
  [[ "$output" == *"username: alice"* ]]
  [[ "$output" == *"url: https://x.com"* ]]
  [[ "$output" == *"email: a@b.com"* ]]
  [[ "$output" == *"otp: JBSWY3DP"* ]]
  [[ "$output" == *"notes: my note"* ]]
}

# ── generate_password ─────────────────────────────────────────────────────────

@test "generate_password: default length 20" {
  load_lib
  pw="$(generate_password)"
  [ "${#pw}" -eq 20 ]
}

@test "generate_password: custom length" {
  load_lib
  pw="$(generate_password 32)"
  [ "${#pw}" -eq 32 ]
}
