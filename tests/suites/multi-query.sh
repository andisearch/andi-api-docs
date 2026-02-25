#!/usr/bin/env bash
# Test suite: Multi-query search

run_multi_query_tests() {
  section "Multi-query"

  # JSON array of queries
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode 'q=["weather in new york", "weather in london"]'
  assert_status "200" "multi-query returns 200"
  assert_json_type ".results" "array" "multi-query results is array"
  assert_json_gte ".metrics.queries_executed" "2" "queries_executed >= 2"
}
