#!/usr/bin/env bash
# Shared test helpers: API calls, assertions, output formatting

set -euo pipefail

# --- Config ---
API_BASE="${ANDI_API_BASE:-https://search-api.andisearch.com}"
API_ENDPOINT="/api/v1/search"
RATE_LIMIT_DELAY=0.5

# --- State ---
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
TOTAL_COUNT=0
HTTP_STATUS=""
RESPONSE_FILE=""

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No color

# --- Setup / Teardown ---

setup() {
  # Check dependencies
  if ! command -v curl &>/dev/null; then
    echo -e "${RED}Error: curl is required but not installed${NC}" >&2
    exit 1
  fi
  if ! command -v jq &>/dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}" >&2
    echo "Install with: brew install jq" >&2
    exit 1
  fi

  # Load .env
  local env_file="${PROJECT_ROOT:-.}/.env"
  if [[ -f "$env_file" ]]; then
    # shellcheck disable=SC1090
    source "$env_file"
  fi

  if [[ -z "${ANDI_API_KEY:-}" ]]; then
    echo -e "${RED}Error: ANDI_API_KEY not set. Copy .env.example to .env and add your key.${NC}" >&2
    exit 1
  fi

  # Create temp file for response bodies
  RESPONSE_FILE=$(mktemp)
}

teardown() {
  if [[ -n "${RESPONSE_FILE:-}" && -f "$RESPONSE_FILE" ]]; then
    rm -f "$RESPONSE_FILE"
  fi
}

# --- API helpers ---

# Make a GET request to the search API
# Usage: api_get "q=test&limit=5" [api_key_override]
api_get() {
  local params="${1:-}"
  local api_key="${2:-$ANDI_API_KEY}"

  sleep "$RATE_LIMIT_DELAY"

  local url="${API_BASE}${API_ENDPOINT}"
  if [[ -n "$params" ]]; then
    url="${url}?${params}"
  fi

  HTTP_STATUS=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" \
    -H "x-api-key: ${api_key}" \
    "$url")
}

# Make a GET request without an API key header
# Usage: api_get_no_key "q=test"
api_get_no_key() {
  local params="${1:-}"

  sleep "$RATE_LIMIT_DELAY"

  local url="${API_BASE}${API_ENDPOINT}"
  if [[ -n "$params" ]]; then
    url="${url}?${params}"
  fi

  HTTP_STATUS=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" "$url")
}

# Make a raw GET request with custom curl args (for --data-urlencode etc.)
# Usage: api_get_raw <curl_args...>
api_get_raw() {
  sleep "$RATE_LIMIT_DELAY"

  HTTP_STATUS=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" \
    -H "x-api-key: ${ANDI_API_KEY}" \
    "$@")
}

# Get the response body
response_body() {
  cat "$RESPONSE_FILE"
}

# --- Output helpers ---

section() {
  echo ""
  echo -e "${BOLD}=== $1 ===${NC}"
}

pass() {
  local name="$1"
  ((PASS_COUNT++)) || true
  ((TOTAL_COUNT++)) || true
  echo -e "  ${GREEN}PASS${NC} $name"
}

fail() {
  local name="$1"
  local detail="${2:-}"
  ((FAIL_COUNT++)) || true
  ((TOTAL_COUNT++)) || true
  echo -e "  ${RED}FAIL${NC} $name"
  if [[ -n "$detail" ]]; then
    echo -e "       ${RED}$detail${NC}"
  fi
}

skip() {
  local name="$1"
  local reason="${2:-}"
  ((SKIP_COUNT++)) || true
  ((TOTAL_COUNT++)) || true
  echo -e "  ${YELLOW}SKIP${NC} $name"
  if [[ -n "$reason" ]]; then
    echo -e "       ${YELLOW}$reason${NC}"
  fi
}

summary() {
  echo ""
  echo -e "${BOLD}--- Results ---${NC}"
  echo -e "  Total:   $TOTAL_COUNT"
  echo -e "  ${GREEN}Passed:  $PASS_COUNT${NC}"
  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "  ${RED}Failed:  $FAIL_COUNT${NC}"
  else
    echo -e "  Failed:  0"
  fi
  if [[ $SKIP_COUNT -gt 0 ]]; then
    echo -e "  ${YELLOW}Skipped: $SKIP_COUNT${NC}"
  fi
  echo ""

  if [[ $FAIL_COUNT -gt 0 ]]; then
    return 1
  fi
  return 0
}

# --- Assertions ---

# Check HTTP status code
assert_status() {
  local expected="$1"
  local name="$2"
  if [[ "$HTTP_STATUS" == "$expected" ]]; then
    pass "$name"
  else
    fail "$name" "expected status $expected, got $HTTP_STATUS"
  fi
}

# Check that a JSON field exists and is non-null
assert_json_field() {
  local jq_path="$1"
  local name="$2"
  local value
  value=$(jq -r "$jq_path // \"__NULL__\"" "$RESPONSE_FILE" 2>/dev/null)
  if [[ "$value" != "__NULL__" && "$value" != "null" ]]; then
    pass "$name"
  else
    fail "$name" "field $jq_path is missing or null"
  fi
}

# Check that a JSON field exists (may be null, empty string, or empty array)
assert_json_field_exists() {
  local jq_path="$1"
  local name="$2"
  local exists
  exists=$(jq -e "$jq_path" "$RESPONSE_FILE" 2>/dev/null && echo "yes" || echo "no")
  if [[ "$exists" == "yes" ]]; then
    pass "$name"
  else
    fail "$name" "field $jq_path does not exist"
  fi
}

# Check jq type of a field
assert_json_type() {
  local jq_path="$1"
  local expected_type="$2"
  local name="$3"
  local actual_type
  actual_type=$(jq -r "$jq_path | type" "$RESPONSE_FILE" 2>/dev/null || echo "error")
  if [[ "$actual_type" == "$expected_type" ]]; then
    pass "$name"
  else
    fail "$name" "expected type $expected_type at $jq_path, got $actual_type"
  fi
}

# Check exact value match
assert_json_value() {
  local jq_path="$1"
  local expected="$2"
  local name="$3"
  local actual
  actual=$(jq -r "$jq_path" "$RESPONSE_FILE" 2>/dev/null || echo "__ERROR__")
  if [[ "$actual" == "$expected" ]]; then
    pass "$name"
  else
    fail "$name" "expected '$expected' at $jq_path, got '$actual'"
  fi
}

# Check array length >= value
assert_json_length_gte() {
  local jq_path="$1"
  local min="$2"
  local name="$3"
  local length
  length=$(jq -r "$jq_path | length" "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$length" -ge "$min" ]]; then
    pass "$name"
  else
    fail "$name" "expected length >= $min at $jq_path, got $length"
  fi
}

# Check array length <= value
assert_json_length_lte() {
  local jq_path="$1"
  local max="$2"
  local name="$3"
  local length
  length=$(jq -r "$jq_path | length" "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$length" -le "$max" ]]; then
    pass "$name"
  else
    fail "$name" "expected length <= $max at $jq_path, got $length"
  fi
}

# Check array length == value
assert_json_length_eq() {
  local jq_path="$1"
  local expected="$2"
  local name="$3"
  local length
  length=$(jq -r "$jq_path | length" "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$length" -eq "$expected" ]]; then
    pass "$name"
  else
    fail "$name" "expected length == $expected at $jq_path, got $length"
  fi
}

# Check that a field contains a substring
assert_json_contains() {
  local jq_path="$1"
  local substring="$2"
  local name="$3"
  local value
  value=$(jq -r "$jq_path" "$RESPONSE_FILE" 2>/dev/null || echo "")
  if [[ "$value" == *"$substring"* ]]; then
    pass "$name"
  else
    fail "$name" "expected '$substring' in $jq_path, got '$value'"
  fi
}

# Check that every element in an array has a given field
assert_each_has_field() {
  local array_path="$1"
  local field="$2"
  local name="$3"
  local missing
  missing=$(jq -r "[$array_path[] | select(.${field} == null)] | length" "$RESPONSE_FILE" 2>/dev/null || echo "-1")
  if [[ "$missing" == "0" ]]; then
    pass "$name"
  elif [[ "$missing" == "-1" ]]; then
    fail "$name" "could not evaluate $array_path"
  else
    fail "$name" "$missing elements in $array_path missing field '$field'"
  fi
}

# Check that response has an error field (for error responses)
assert_error_response() {
  local name="$1"
  assert_json_field ".error" "$name"
}

# Check that a numeric field is >= value
assert_json_gte() {
  local jq_path="$1"
  local min="$2"
  local name="$3"
  local value
  value=$(jq -r "$jq_path" "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if (( $(echo "$value >= $min" | bc -l 2>/dev/null || echo "0") )); then
    pass "$name"
  else
    fail "$name" "expected $jq_path >= $min, got $value"
  fi
}

# Check that a string field matches a regex
assert_json_matches() {
  local jq_path="$1"
  local pattern="$2"
  local name="$3"
  local value
  value=$(jq -r "$jq_path" "$RESPONSE_FILE" 2>/dev/null || echo "")
  if [[ "$value" =~ $pattern ]]; then
    pass "$name"
  else
    fail "$name" "expected $jq_path to match '$pattern', got '$value'"
  fi
}
