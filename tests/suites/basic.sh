#!/usr/bin/env bash
# Test suite: Basic search functionality

run_basic_tests() {
  section "Basic search"

  api_get "q=test+search"
  assert_status "200" "basic search returns 200"
  assert_json_field ".results_type" "response has results_type"
  assert_json_type ".results" "array" "results is an array"
  assert_json_field ".metrics" "response has metrics"
  # answer field may be absent on some queries — check type if present
  if jq -e 'has("answer")' "$RESPONSE_FILE" &>/dev/null; then
    pass "response has answer field"
  else
    skip "response has answer field" "answer field not present (may depend on query)"
  fi
  assert_json_field ".type" "response has type"
  assert_json_field ".title" "response has title"
}
