#!/usr/bin/env bats
# tests/validation.bats

load test_helper

setup() { load_lib; }

# ── validate_password ─────────────────────────────────────────────────────────

@test "password: valid strong password passes" {
  run validate_password "Abcdef1!"
  [ "$status" -eq 0 ]
}

@test "password: too short fails" {
  run validate_password "Ab1!"
  [ "$status" -ne 0 ]
}

@test "password: missing uppercase fails" {
  run validate_password "abcdef1!"
  [ "$status" -ne 0 ]
}

@test "password: missing lowercase fails" {
  run validate_password "ABCDEF1!"
  [ "$status" -ne 0 ]
}

@test "password: missing digit fails" {
  run validate_password "Abcdefg!"
  [ "$status" -ne 0 ]
}

@test "password: missing symbol fails" {
  run validate_password "Abcdef12"
  [ "$status" -ne 0 ]
}

# ── validate_username ─────────────────────────────────────────────────────────

@test "username: non-empty passes" {
  run validate_username "alice"
  [ "$status" -eq 0 ]
}

@test "username: empty fails" {
  run validate_username ""
  [ "$status" -ne 0 ]
}

# ── validate_url ──────────────────────────────────────────────────────────────

@test "url: empty passes (optional)" {
  run validate_url ""
  [ "$status" -eq 0 ]
}

@test "url: https passes" {
  run validate_url "https://example.com"
  [ "$status" -eq 0 ]
}

@test "url: http passes" {
  run validate_url "http://example.com"
  [ "$status" -eq 0 ]
}

@test "url: no scheme fails" {
  run validate_url "example.com"
  [ "$status" -ne 0 ]
}

# ── validate_otp ──────────────────────────────────────────────────────────────

@test "otp: empty passes (optional)" {
  run validate_otp ""
  [ "$status" -eq 0 ]
}

@test "otp: valid base32 passes" {
  run validate_otp "JBSWY3DPEHPK3PXP"
  [ "$status" -eq 0 ]
}

@test "otp: invalid chars fails" {
  run validate_otp "invalid-otp-123"
  [ "$status" -ne 0 ]
}
