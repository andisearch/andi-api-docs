#!/usr/bin/env bash
# Test suite: Date filtering (dateRange, dateFrom, dateTo)

run_date_filter_tests() {
  section "Date filtering"

  # Each dateRange value
  local ranges=(day week month year 24h 7d 30d 90d 1y)
  for range in "${ranges[@]}"; do
    api_get "q=technology+news&dateRange=${range}"
    assert_status "200" "dateRange=$range returns 200"
  done

  # dateFrom
  api_get "q=technology&dateFrom=2025-01-01"
  assert_status "200" "dateFrom returns 200"

  # dateTo
  api_get "q=technology&dateTo=2025-12-31"
  assert_status "200" "dateTo returns 200"

  # Combined dateFrom + dateTo
  api_get "q=technology&dateFrom=2025-01-01&dateTo=2025-12-31"
  assert_status "200" "dateFrom + dateTo returns 200"
}
