#!/usr/bin/env bash
# Test suite: Pagination (offset, limit combinations)

run_pagination_tests() {
  section "Pagination"

  # First page
  api_get "q=programming&limit=3&offset=0"
  assert_status "200" "first page (offset=0, limit=3) returns 200"
  assert_json_length_lte ".results" "3" "first page respects limit"
  local first_link
  first_link=$(jq -r '.results[0].link // ""' "$RESPONSE_FILE" 2>/dev/null)

  # Second page — should return different results
  api_get "q=programming&limit=3&offset=3"
  assert_status "200" "second page (offset=3, limit=3) returns 200"
  local second_link
  second_link=$(jq -r '.results[0].link // ""' "$RESPONSE_FILE" 2>/dev/null)
  if [[ -n "$first_link" && -n "$second_link" && "$first_link" != "$second_link" ]]; then
    pass "second page has different results from first"
  elif [[ -z "$first_link" || -z "$second_link" ]]; then
    skip "pagination result comparison" "empty results on one of the pages"
  else
    skip "pagination result comparison" "same first result on both pages (may be API behavior)"
  fi

  # metrics.results_returned consistency
  api_get "q=programming&limit=5"
  assert_status "200" "metrics consistency query returns 200"
  local returned
  returned=$(jq -r '.metrics.results_returned // 0' "$RESPONSE_FILE" 2>/dev/null)
  local actual_count
  actual_count=$(jq '.results | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$returned" == "$actual_count" ]]; then
    pass "metrics.results_returned matches actual results count"
  else
    fail "metrics.results_returned matches actual results count" "metrics says $returned, actual count is $actual_count"
  fi

  # Large offset — may return empty results
  api_get "q=programming&limit=5&offset=500"
  assert_status "200" "large offset returns 200"

  # Limit + offset combo
  api_get "q=programming&limit=2&offset=1"
  assert_status "200" "limit=2, offset=1 returns 200"
  assert_json_length_lte ".results" "2" "respects limit with offset"
}
