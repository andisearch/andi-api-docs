#!/usr/bin/env bash
# Test suite: searchMode dial and reranker parameter

run_search_modes_tests() {
  section "Search modes"

  local modes=(auto fast low-cost balanced deep exhaustive)
  for mode in "${modes[@]}"; do
    api_get "q=test+search&searchMode=${mode}"
    assert_status "200" "searchMode=${mode} returns 200"
  done

  # invalid searchMode — 400
  api_get "q=test&searchMode=bogus"
  assert_status "400" "invalid searchMode returns 400"
  assert_error_response "invalid searchMode has error field"

  # legacy depth alias still works
  api_get "q=test+search&depth=fast"
  assert_status "200" "legacy depth=fast returns 200"

  # reranker tier
  api_get "q=test+search&reranker=small"
  assert_status "200" "reranker=small returns 200"

  # invalid reranker — 400
  api_get "q=test&reranker=bogus"
  assert_status "400" "invalid reranker returns 400"
  assert_error_response "invalid reranker has error field"
}
