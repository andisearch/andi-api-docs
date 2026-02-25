#!/usr/bin/env bash
# Test suite: Response structure validation

run_response_tests() {
  section "Response structure"

  # Full response field validation
  api_get "q=programming+languages&limit=5"
  assert_status "200" "response query returns 200"

  # Required top-level fields (per OpenAPI spec)
  assert_json_field ".results_type" "has results_type"
  # answer may be absent on some queries
  if jq -e 'has("answer")' "$RESPONSE_FILE" &>/dev/null; then
    pass "has answer"
  else
    skip "has answer" "answer field not present (may depend on query)"
  fi
  assert_json_field ".type" "has type"
  assert_json_field ".title" "has title"
  assert_json_type ".results" "array" "results is array"
  assert_json_field ".metrics" "has metrics"

  # Result required fields (per SearchResult schema)
  local result_count
  result_count=$(jq '.results | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$result_count" -gt 0 ]]; then
    assert_each_has_field ".results" "title" "each result has title"
    assert_each_has_field ".results" "link" "each result has link"
    assert_each_has_field ".results" "desc" "each result has desc"
    assert_each_has_field ".results" "source" "each result has source"
    assert_each_has_field ".results" "type" "each result has type"
  else
    skip "result field validation" "no results returned"
  fi

  # Result type enum values
  if [[ "$result_count" -gt 0 ]]; then
    local valid_types="website|news|video|image|place|profile|social|academic|calculation|weather|computation|instant answer"
    local invalid_count
    invalid_count=$(jq --arg types "$valid_types" \
      '[.results[] | select(.type != null) | select(.type | test($types) | not)] | length' \
      "$RESPONSE_FILE" 2>/dev/null || echo "-1")
    if [[ "$invalid_count" == "0" ]]; then
      pass "all result types are valid enum values"
    elif [[ "$invalid_count" == "-1" ]]; then
      skip "result type enum check" "could not evaluate"
    else
      fail "all result types are valid enum values" "$invalid_count results with unknown type"
    fi
  fi

  # Metrics fields
  assert_json_field ".metrics.query" "metrics has query"
  assert_json_field ".metrics.intent" "metrics has intent"
  assert_json_field ".metrics.duration" "metrics has duration"
  assert_json_field ".metrics.results_returned" "metrics has results_returned"

  # Weather response structure (if we can get one)
  api_get "q=weather+new+york&intent=weather"
  assert_status "200" "weather response returns 200"
  if jq -e '.weather' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_field ".weather.location.name" "weather location has name"
    assert_json_field ".weather.temperature" "weather has temperature"
    assert_json_field ".weather.units" "weather has units"
    assert_json_field ".weather.description" "weather has description"
  else
    skip "weather response structure" "weather object not present"
  fi

  # Calculation response structure
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=125 * 37"
  assert_status "200" "calculation response returns 200"
  if jq -e '.calculation' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_field ".calculation.expression" "calculation has expression"
    assert_json_field ".calculation.result" "calculation has result"
  else
    skip "calculation response structure" "calculation object not present"
  fi

  # Image response structure
  api_get "q=sunset+photos&intent=images"
  assert_status "200" "images response returns 200"
  if jq -e '.images[0]' "$RESPONSE_FILE" &>/dev/null; then
    local img_fields=("title" "link" "image" "source" "type")
    for field in "${img_fields[@]}"; do
      local val
      val=$(jq -r ".images[0].${field} // \"__NULL__\"" "$RESPONSE_FILE" 2>/dev/null)
      if [[ "$val" != "__NULL__" && "$val" != "null" ]]; then
        pass "image result has $field"
      else
        fail "image result has $field" "field missing on first image result"
      fi
    done
  else
    skip "image result structure" "no image results returned"
  fi
}
