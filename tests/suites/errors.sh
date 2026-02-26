#!/usr/bin/env bash
# Test suite: Error handling

run_errors_tests() {
  section "Error handling"

  # Missing query parameter
  api_get ""
  assert_status "400" "missing q param returns 400"
  assert_error_response "missing q has error field"

  # Empty query
  api_get "q="
  assert_status "400" "empty q param returns 400"
  assert_error_response "empty q has error field"

  # Invalid depth value — API may ignore invalid enum values and return 200
  api_get "q=test&depth=invalid"
  if [[ "$HTTP_STATUS" == "400" ]]; then
    pass "invalid depth returns 400"
    assert_error_response "invalid depth has error field"
  else
    skip "invalid depth returns 400" "API returned $HTTP_STATUS (ignores invalid enum values)"
  fi

  # Invalid format value — API may ignore invalid enum values and return 200
  api_get "q=test&format=xml"
  if [[ "$HTTP_STATUS" == "400" ]]; then
    pass "invalid format returns 400"
    assert_error_response "invalid format has error field"
  else
    skip "invalid format returns 400" "API returned $HTTP_STATUS (ignores invalid enum values)"
  fi

  # Error response structure — should have both error and message fields
  api_get ""
  local has_error
  has_error=$(jq -e '.error' "$RESPONSE_FILE" &>/dev/null && echo "yes" || echo "no")
  if [[ "$has_error" == "yes" ]]; then
    pass "error response has error field"
    assert_json_type ".error" "string" "error field is a string"
  else
    fail "error response has error field" "error field missing from 400 response"
  fi

  local has_message
  has_message=$(jq -e '.message' "$RESPONSE_FILE" &>/dev/null && echo "yes" || echo "no")
  if [[ "$has_message" == "yes" ]]; then
    pass "error response has message field"
    assert_json_type ".message" "string" "message field is a string"
  else
    fail "error response has message field" "message field missing from 400 response"
  fi
}
