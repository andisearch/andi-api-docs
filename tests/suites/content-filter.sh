#!/usr/bin/env bash
# Test suite: Content filtering (filetype, intitle, inurl, intext)

run_content_filter_tests() {
  section "Content filtering"

  # filetype
  api_get "q=machine+learning&filetype=pdf"
  assert_status "200" "filetype=pdf returns 200"

  # intitle
  api_get "q=programming&intitle=guide"
  assert_status "200" "intitle returns 200"

  # inurl
  api_get "q=programming&inurl=tutorial"
  assert_status "200" "inurl returns 200"

  # intext
  api_get "q=programming&intext=python"
  assert_status "200" "intext returns 200"
}
