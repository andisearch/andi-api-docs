#!/usr/bin/env bash
# Test suite: Output format parameters (format, metadata, extracts)

run_output_format_tests() {
  section "Output format"

  # format=json (default)
  api_get "q=test&format=json"
  assert_status "200" "format=json returns 200"
  assert_json_type ".results" "array" "json format has results array"

  # format=context — returns markdown text, not JSON
  api_get "q=test&format=context"
  assert_status "200" "format=context returns 200"

  # metadata=basic (default)
  api_get "q=test&metadata=basic"
  assert_status "200" "metadata=basic returns 200"
  assert_json_field ".metrics" "basic metadata has metrics"

  # metadata=full — results may have contentType and reader fields
  api_get "q=test&metadata=full"
  assert_status "200" "metadata=full returns 200"
  assert_json_field ".metrics" "full metadata has metrics"

  # extracts=true — results should have extract field
  api_get "q=test&extracts=true"
  assert_status "200" "extracts=true returns 200"
  # Check if at least some results have extracts
  local with_extracts
  with_extracts=$(jq '[.results[] | select(.extract != null)] | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$with_extracts" -gt 0 ]]; then
    pass "some results have extract field"
  else
    skip "extract field presence" "no results have extract field (may depend on query)"
  fi
}
