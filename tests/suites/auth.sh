#!/usr/bin/env bash
# Test suite: Authentication

run_auth_tests() {
  section "Authentication"

  # Valid API key
  api_get "q=test"
  assert_status "200" "valid API key returns 200"

  # Missing API key
  api_get_no_key "q=test"
  assert_status "401" "missing API key returns 401"
  assert_error_response "missing key has error field"

  # Invalid API key
  api_get "q=test" "invalid-key-12345"
  assert_status "401" "invalid API key returns 401"
  assert_error_response "invalid key has error field"
}
