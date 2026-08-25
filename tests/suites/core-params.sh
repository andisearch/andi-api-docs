#!/usr/bin/env bash
# Test suite: Core parameters (q, limit, offset, depth)
# `depth` is a legacy, no-longer-documented alias for `searchMode`. It is tested here
# only for backward-compatibility with existing integrations, not as documented behavior.

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

  # content=true — enriched content (reader fields ride metadata=full)
  api_get "q=programming+languages&limit=2&content=true&metadata=full"
  assert_status "200" "content=true returns 200"

  # enrichContent=true — deprecated alias for content
  api_get "q=programming+languages&limit=2&enrichContent=true&metadata=full"
  assert_status "200" "enrichContent=true (deprecated alias) returns 200"
}
