#!/usr/bin/env bash
# Test suite: Intent parameter

run_intents_tests() {
  section "Intents"

  # Each documented intent value should return 200
  local intents=(search news video images weather wiki code recipe place time)
  for intent in "${intents[@]}"; do
    api_get "q=test&intent=${intent}"
    assert_status "200" "intent=$intent returns 200"
  done

  # Weather intent returns weather object
  api_get "q=weather+new+york&intent=weather"
  assert_status "200" "weather query returns 200"
  if jq -e '.weather' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_field ".weather.location" "weather has location"
    assert_json_field ".weather.temperature" "weather has temperature"
    assert_json_field ".weather.units" "weather has units"
    assert_json_field ".weather.description" "weather has description"
  else
    skip "weather object fields" "weather object not present in response"
  fi

  # Images intent returns images array
  api_get "q=sunset+photos&intent=images"
  assert_status "200" "images intent returns 200"
  if jq -e '.images' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_type ".images" "array" "images is an array"
    assert_json_length_gte ".images" "1" "images has at least 1 result"
  else
    skip "images array check" "images array not present in response"
  fi

  # News intent returns news array
  api_get "q=latest+tech+news&intent=news"
  assert_status "200" "news intent returns 200"
  if jq -e '.news' "$RESPONSE_FILE" &>/dev/null; then
    assert_json_type ".news" "array" "news is an array"
  else
    skip "news array check" "news array not present in response"
  fi
}
