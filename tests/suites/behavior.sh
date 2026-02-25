#!/usr/bin/env bash
# Test suite: Behavior parameters (noCache, parseOperators)

run_behavior_tests() {
  section "Behavior parameters"

  # noCache=true
  api_get "q=test+behavior&noCache=true"
  assert_status "200" "noCache=true returns 200"

  # parseOperators=true (default)
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=site:github.com test" \
    -d "parseOperators=true"
  assert_status "200" "parseOperators=true returns 200"

  # parseOperators=false — site: should be treated as literal text
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=site:github.com test" \
    -d "parseOperators=false"
  assert_status "200" "parseOperators=false returns 200"
}
