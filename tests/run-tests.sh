#!/usr/bin/env bash
# Test runner for Andi Search API documentation tests
#
# Usage:
#   ./tests/run-tests.sh              # Run all suites (72 API calls)
#   ./tests/run-tests.sh --quick      # Run core suites only (17 API calls)
#   ./tests/run-tests.sh auth errors  # Run specific suites
#   ./tests/run-tests.sh --list       # List available suites

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SUITES_DIR="$SCRIPT_DIR/suites"
HELPERS="$SCRIPT_DIR/lib/helpers.sh"

# All available suites in execution order
ALL_SUITES=(
  auth
  basic
  core-params
  multi-query
  intents
  output-format
  domain-filter
  date-filter
  content-filter
  term-filter
  localization
  operators
  behavior
  response
  errors
  pagination
)

# Core suites for quick smoke tests (auth, basic search, params, errors, response)
QUICK_SUITES=(
  auth
  basic
  core-params
  errors
  response
)

# --- List mode ---
if [[ "${1:-}" == "--list" ]]; then
  echo "Available test suites:"
  for suite in "${ALL_SUITES[@]}"; do
    local_marker=""
    for qs in "${QUICK_SUITES[@]}"; do
      if [[ "$suite" == "$qs" ]]; then local_marker=" (quick)"; break; fi
    done
    echo "  $suite$local_marker"
  done
  exit 0
fi

# --- Determine which suites to run ---
QUICK_MODE=false
if [[ "${1:-}" == "--quick" ]]; then
  QUICK_MODE=true
  SUITES=("${QUICK_SUITES[@]}")
  shift
elif [[ $# -gt 0 ]]; then
  SUITES=("$@")
  # Validate suite names
  for suite in "${SUITES[@]}"; do
    suite_file="$SUITES_DIR/${suite}.sh"
    if [[ ! -f "$suite_file" ]]; then
      echo "Error: unknown suite '$suite'. Run with --list to see available suites." >&2
      exit 1
    fi
  done
else
  SUITES=("${ALL_SUITES[@]}")
fi
export QUICK_MODE

# --- Load helpers and initialize ---
# shellcheck disable=SC1090
source "$HELPERS"
setup

trap teardown EXIT

echo ""
if [[ "$QUICK_MODE" == "true" ]]; then
  echo -e "${BOLD}Andi Search API — Quick Tests${NC}"
else
  echo -e "${BOLD}Andi Search API — Test Suite${NC}"
fi
echo "Running ${#SUITES[@]} suite(s): ${SUITES[*]}"

# --- Run suites ---
for suite in "${SUITES[@]}"; do
  suite_file="$SUITES_DIR/${suite}.sh"
  # shellcheck disable=SC1090
  source "$suite_file"

  # Call the suite's run function (suite name with hyphens replaced by underscores)
  func_name="run_${suite//-/_}_tests"
  if declare -f "$func_name" &>/dev/null; then
    "$func_name"
  else
    echo -e "${RED}Error: suite '$suite' does not define function $func_name${NC}" >&2
    exit 1
  fi
done

# --- Mintlify validation (optional) ---
if command -v mint &>/dev/null; then
  section "Mintlify validation"

  echo -n "  openapi-check... "
  if mint openapi-check "$PROJECT_ROOT/api-reference/openapi.json" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${RED}FAILED${NC}"
    ((FAIL_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
  fi

  echo -n "  validate... "
  if (cd "$PROJECT_ROOT" && mint validate) &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${RED}FAILED${NC}"
    ((FAIL_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
  fi

  echo -n "  broken-links... "
  if (cd "$PROJECT_ROOT" && mint broken-links) &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${RED}FAILED${NC}"
    ((FAIL_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
  fi
else
  echo ""
  echo -e "${YELLOW}Note: mint CLI not installed — skipping Mintlify validation${NC}"
fi

# --- Summary ---
summary
