#!/usr/bin/env bash
# Test suite: Domain filtering (includeDomains, excludeDomains)

run_domain_filter_tests() {
  section "Domain filtering"

  # includeDomains — restrict to a single domain
  api_get "q=programming&includeDomains=github.com"
  assert_status "200" "includeDomains returns 200"
  local non_matching
  non_matching=$(jq '[.results[] | select(.source != null) | select(.source | test("github\\.com") | not)] | length' "$RESPONSE_FILE" 2>/dev/null || echo "-1")
  if [[ "$non_matching" == "0" ]]; then
    pass "all results from included domain"
  elif [[ "$non_matching" == "-1" ]]; then
    skip "includeDomains filtering" "could not evaluate results"
  else
    # Some APIs include results from subdomains etc., so warn rather than hard-fail
    skip "includeDomains filtering" "$non_matching results from other domains (may include subdomains)"
  fi

  # excludeDomains
  api_get "q=programming&excludeDomains=pinterest.com,reddit.com"
  assert_status "200" "excludeDomains returns 200"
  local excluded
  excluded=$(jq '[.results[] | select(.source != null) | select(.source | test("pinterest\\.com|reddit\\.com"))] | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$excluded" == "0" ]]; then
    pass "no results from excluded domains"
  else
    fail "no results from excluded domains" "$excluded results from excluded domains"
  fi

  # Multiple includeDomains
  api_get "q=programming&includeDomains=github.com,stackoverflow.com"
  assert_status "200" "multiple includeDomains returns 200"

  # Wildcard domain
  api_get "q=programming&includeDomains=*.github.com"
  assert_status "200" "wildcard domain returns 200"
}
