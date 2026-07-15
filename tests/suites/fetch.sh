#!/usr/bin/env bash
# Test suite: Fetch endpoint (GET /api/v1/fetch)

FETCH_ENDPOINT="/api/v1/fetch"
FETCH_TARGET_ENCODED="https%3A%2F%2Fexample.com%2F"
FETCH_PRIVATE_IP_ENCODED="http%3A%2F%2F127.0.0.1%2F"
FETCH_HARD_TARGET_ENCODED="https%3A%2F%2Fhttpbin.org%2Fimage%2Fpng"

run_fetch_tests() {
  section "Fetch endpoint"

  # json (default) — 200 with core fields present
  api_get_endpoint "$FETCH_ENDPOINT" "url=${FETCH_TARGET_ENCODED}"
  if [[ "$HTTP_STATUS" == "200" ]]; then
    pass "fetch json returns 200"
    assert_json_field ".title" "fetch json has title"
    assert_json_field ".content" "fetch json has content"
    assert_json_field ".word_count" "fetch json has word_count"
    assert_json_field ".metrics.cost_dollars" "fetch json has metrics.cost_dollars"
  elif [[ "$HTTP_STATUS" == "422" || "$HTTP_STATUS" == "503" ]]; then
    skip "fetch json returns 200" "target returned $HTTP_STATUS (extraction failure/warming, not a docs bug)"
  else
    fail "fetch json returns 200" "expected 200, got $HTTP_STATUS"
  fi

  # format=context — markdown with YAML frontmatter
  api_get_endpoint "$FETCH_ENDPOINT" "url=${FETCH_TARGET_ENCODED}&format=context"
  if [[ "$HTTP_STATUS" == "200" ]]; then
    pass "fetch format=context returns 200"
    if response_body | grep -q "^---$"; then
      pass "fetch context response has frontmatter delimiter"
    else
      fail "fetch context response has frontmatter delimiter" "no --- delimiter found in body"
    fi
    if response_body | grep -q "^url:"; then
      pass "fetch context frontmatter has url"
    else
      fail "fetch context frontmatter has url" "no url: line found in body"
    fi
  elif [[ "$HTTP_STATUS" == "422" || "$HTTP_STATUS" == "503" ]]; then
    skip "fetch format=context returns 200" "target returned $HTTP_STATUS (extraction failure/warming, not a docs bug)"
  else
    fail "fetch format=context returns 200" "expected 200, got $HTTP_STATUS"
  fi

  # maxContentLength — content respected and truncated flag set
  api_get_endpoint "$FETCH_ENDPOINT" "url=${FETCH_TARGET_ENCODED}&maxContentLength=50"
  if [[ "$HTTP_STATUS" == "200" ]]; then
    pass "fetch maxContentLength returns 200"
    local content_len
    content_len=$(jq -r '.content | length' "$RESPONSE_FILE" 2>/dev/null || echo "-1")
    if [[ "$content_len" -le 50 ]]; then
      pass "fetch content respects maxContentLength"
    else
      fail "fetch content respects maxContentLength" "expected content length <= 50, got $content_len"
    fi
    assert_json_value ".truncated" "true" "fetch response flags truncated"
  elif [[ "$HTTP_STATUS" == "422" || "$HTTP_STATUS" == "503" ]]; then
    skip "fetch maxContentLength returns 200" "target returned $HTTP_STATUS (extraction failure/warming, not a docs bug)"
  else
    fail "fetch maxContentLength returns 200" "expected 200, got $HTTP_STATUS"
  fi

  # missing url — 400
  api_get_endpoint "$FETCH_ENDPOINT" ""
  assert_status "400" "fetch missing url returns 400"
  assert_error_response "fetch missing url has error field"

  # private-IP url — 400 (SSRF boundary guard)
  api_get_endpoint "$FETCH_ENDPOINT" "url=${FETCH_PRIVATE_IP_ENCODED}"
  assert_status "400" "fetch private-IP url returns 400"
  assert_error_response "fetch private-IP url has error field"

  # hard-to-extract url — tolerate 422/503 without hard-failing the suite
  api_get_endpoint "$FETCH_ENDPOINT" "url=${FETCH_HARD_TARGET_ENCODED}"
  case "$HTTP_STATUS" in
    200|422|503)
      pass "fetch hard-to-extract url tolerated ($HTTP_STATUS)"
      ;;
    *)
      fail "fetch hard-to-extract url tolerated" "unexpected status $HTTP_STATUS"
      ;;
  esac
}
