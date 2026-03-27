#!/usr/bin/env bash
# validation.sh — input validation functions

validate_password() {
  local pw="$1"
  [[ ${#pw} -ge 8 ]] || {
    echo "Password must be at least 8 characters."
    return 1
  }
  [[ "$pw" =~ [A-Z] ]] || {
    echo "Password must contain an uppercase letter."
    return 1
  }
  [[ "$pw" =~ [a-z] ]] || {
    echo "Password must contain a lowercase letter."
    return 1
  }
  [[ "$pw" =~ [0-9] ]] || {
    echo "Password must contain a digit."
    return 1
  }
  [[ "$pw" =~ [^a-zA-Z0-9] ]] || {
    echo "Password must contain a symbol."
    return 1
  }
  return 0
}

validate_username() {
  local u="$1"
  [[ -n "$u" ]] || {
    echo "Username is required."
    return 1
  }
  return 0
}

validate_url() {
  local url="$1"
  [[ -z "$url" ]] && return 0
  [[ "$url" =~ ^https?:// ]] || {
    echo "URL must start with http:// or https://"
    return 1
  }
  return 0
}

validate_otp() {
  local otp="$1"
  [[ -z "$otp" ]] && return 0
  [[ "$otp" =~ ^[A-Z2-7]+=*$ ]] || {
    echo "OTP secret must be valid base32 (A-Z, 2-7)."
    return 1
  }
  return 0
}
