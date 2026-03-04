#!/usr/bin/env bash
# Test suite: Example page patterns
# Validates the API call patterns documented in examples/*.mdx

run_examples_tests() {

  # --- Basic search (examples/basic-search.mdx) ---

  section "Examples — basic search"

  # q=...&limit=5 (main example)
  api_get "q=best+programming+languages+2025&limit=5"
  assert_status "200" "basic search with limit returns 200"
  assert_json_type ".results" "array" "results is an array"
  assert_json_length_lte ".results" "5" "results count <= limit"

  # q=...&extracts=true (variation: with text extracts)
  api_get "q=best+programming+languages+2025&extracts=true"
  assert_status "200" "search with extracts returns 200"
  if jq -e '[.results[] | select(.extracts != null)] | length > 0' "$RESPONSE_FILE" &>/dev/null; then
    pass "some results have extracts array"
  else
    skip "some results have extracts array" "no extracts returned (may depend on query)"
  fi

  # q=...&format=context (variation: context format for LLMs)
  api_get "q=best+programming+languages+2025&format=context"
  assert_status "200" "format=context returns 200"

  # --- RAG pipeline (examples/rag-pipeline.mdx) ---

  section "Examples — RAG pipeline"

  # q=...&extracts=true&limit=5 (main example)
  api_get "q=what+causes+aurora+borealis&extracts=true&limit=5"
  assert_status "200" "RAG search returns 200"
  assert_each_has_field ".results" "title" "RAG results have title"
  assert_each_has_field ".results" "link" "RAG results have link"
  assert_each_has_field ".results" "desc" "RAG results have desc"

  # q=...&depth=deep&extracts=true&limit=10 (variation: deep search)
  api_get "q=what+causes+aurora+borealis&depth=deep&extracts=true&limit=10"
  assert_status "200" "deep RAG search returns 200"
  assert_json_length_lte ".results" "10" "deep results count <= limit"

  # --- AI agent tool (examples/ai-agent-tool.mdx) ---

  section "Examples — AI agent tool"

  # q=...&limit=5&extracts=true (tool execution pattern)
  api_get "q=latest+developments+quantum+computing&limit=5&extracts=true"
  assert_status "200" "agent tool search returns 200"
  assert_each_has_field ".results" "title" "agent results have title"
  assert_each_has_field ".results" "link" "agent results have link"
  assert_each_has_field ".results" "desc" "agent results have desc"
  assert_each_has_field ".results" "source" "agent results have source"

  # --- News monitoring (examples/news-monitoring.mdx) ---

  section "Examples — news monitoring"

  # q=...&intent=news&dateRange=24h&limit=10 (main example)
  api_get "q=artificial+intelligence&intent=news&dateRange=24h&limit=10"
  assert_status "200" "news search returns 200"
  # News results may appear in either .results or .news
  if jq -e '.news // .results | length > 0' "$RESPONSE_FILE" &>/dev/null; then
    pass "news search has results"
  else
    skip "news search has results" "no news results for this query/timeframe"
  fi

  # q=...&intent=news&dateRange=week&includeDomains=... (variation: trusted sources)
  api_get "q=artificial+intelligence&intent=news&dateRange=week&includeDomains=arstechnica.com,wired.com"
  assert_status "200" "news with includeDomains returns 200"

  # q=...&intent=news&excludeDomains=reddit.com,medium.com (variation: exclude aggregators)
  api_get "q=AI+startups+funding&intent=news&dateRange=week&excludeDomains=reddit.com,medium.com"
  assert_status "200" "news with excludeDomains returns 200"
  # Verify excluded domains are not in results
  local excluded_count
  excluded_count=$(jq -r '[(.results // [])[] | select(.link | test("reddit\\.com|medium\\.com"))] | length' "$RESPONSE_FILE" 2>/dev/null || echo "0")
  if [[ "$excluded_count" == "0" ]]; then
    pass "no excluded domains in results"
  else
    fail "no excluded domains in results" "found $excluded_count results from excluded domains"
  fi

  # --- Research assistant (examples/research-assistant.mdx) ---

  section "Examples — research assistant"

  # q=...&depth=deep&limit=10&extracts=true (single deep query)
  api_get "q=quantum+computing+applications&depth=deep&limit=10&extracts=true"
  assert_status "200" "deep research search returns 200"
  assert_json_type ".results" "array" "research results is array"

  # Multi-query JSON array: q=["q1","q2"]&depth=deep&limit=10
  api_get_raw -G "${API_BASE}${API_ENDPOINT}" \
    --data-urlencode 'q=["quantum computing applications", "quantum computing challenges"]' \
    -d "depth=deep" \
    -d "limit=10"
  assert_status "200" "multi-query research returns 200"
  assert_json_type ".results" "array" "multi-query results is array"
}
