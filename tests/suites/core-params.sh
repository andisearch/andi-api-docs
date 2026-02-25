#!/usr/bin/env bash
# Test suite: Core parameters (q, limit, offset, depth)

run_core_params_tests() {
  section "Core parameters"

  # limit
  api_get "q=programming+languages&limit=3"
  assert_status "200" "limit=3 returns 200"
  assert_json_length_lte ".results" "3" "results count <= limit"

  # limit=1
  api_get "q=programming+languages&limit=1"
  assert_status "200" "limit=1 returns 200"
  assert_json_length_lte ".results" "1" "limit=1 returns at most 1 result"

  # depth=fast
  api_get "q=programming+languages&depth=fast"
  assert_status "200" "depth=fast returns 200"

  # depth=deep
  api_get "q=programming+languages&depth=deep"
  assert_status "200" "depth=deep returns 200"
}
