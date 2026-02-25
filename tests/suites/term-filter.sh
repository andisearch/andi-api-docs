#!/usr/bin/env bash
# Test suite: Term filtering (includeTerms, excludeTerms)

run_term_filter_tests() {
  section "Term filtering"

  # includeTerms
  api_get "q=programming+languages&includeTerms=python"
  assert_status "200" "includeTerms returns 200"

  # excludeTerms
  api_get "q=programming+languages&excludeTerms=java"
  assert_status "200" "excludeTerms returns 200"

  # Combined
  api_get "q=programming+languages&includeTerms=python&excludeTerms=java"
  assert_status "200" "includeTerms + excludeTerms returns 200"
}
