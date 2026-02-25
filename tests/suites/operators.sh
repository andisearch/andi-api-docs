#!/usr/bin/env bash
# Test suite: Query operators

run_operators_tests() {
  section "Query operators"

  # site: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=site:github.com python"
  assert_status "200" "site: operator returns 200"

  # -site: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=-site:pinterest.com recipes"
  assert_status "200" "-site: operator returns 200"

  # +term (must include)
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=+python programming"
  assert_status "200" "+term operator returns 200"

  # -term (must exclude)
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=python -java programming"
  assert_status "200" "-term operator returns 200"

  # filetype: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=filetype:pdf machine learning"
  assert_status "200" "filetype: operator returns 200"

  # intitle: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=intitle:guide python"
  assert_status "200" "intitle: operator returns 200"

  # inurl: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=inurl:docs python"
  assert_status "200" "inurl: operator returns 200"

  # intext: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=intext:tutorial python"
  assert_status "200" "intext: operator returns 200"

  # after: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=after:2025-01-01 technology"
  assert_status "200" "after: operator returns 200"

  # before: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=before:2026-01-01 technology"
  assert_status "200" "before: operator returns 200"

  # lang: operator
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=lang:en technology"
  assert_status "200" "lang: operator returns 200"

  # Combined operators
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode "q=site:github.com filetype:md python"
  assert_status "200" "combined operators returns 200"
}
