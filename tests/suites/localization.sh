#!/usr/bin/env bash
# Test suite: Localization (country, language, safe, units)

run_localization_tests() {
  section "Localization"

  # country=US
  api_get "q=news&country=US"
  assert_status "200" "country=US returns 200"

  # country=GB
  api_get "q=news&country=GB"
  assert_status "200" "country=GB returns 200"

  # country=DE
  api_get "q=nachrichten&country=DE"
  assert_status "200" "country=DE returns 200"

  # language
  api_get "q=news&language=en"
  assert_status "200" "language=en returns 200"

  api_get "q=news&language=es"
  assert_status "200" "language=es returns 200"

  # safe search
  api_get "q=test&safe=true"
  assert_status "200" "safe=true returns 200"

  # units=metric (weather query to verify units field)
  api_get "q=weather+london&intent=weather&units=metric"
  assert_status "200" "units=metric returns 200"
  if jq -e '.weather.units' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_value ".weather.units" "metric" "weather units is metric"
  else
    skip "weather units=metric check" "weather object not present"
  fi

  # units=imperial
  api_get "q=weather+new+york&intent=weather&units=imperial"
  assert_status "200" "units=imperial returns 200"
  if jq -e '.weather.units' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_value ".weather.units" "imperial" "weather units is imperial"
  else
    skip "weather units=imperial check" "weather object not present"
  fi
}
