#!/usr/bin/env roundup

ENV="testing" source ./install.sh

describe "nvm_error"

it_exits_with_error_code() {
  local code
  $( nvm_error error ) && code="OK_$?" || code="KO_$?"
  test "$code" = "KO_1"
}

it_has_nothing_executed_after() {
  local after
  $( nvm_error error; after="not set" ) && : || :
  test -z "$after"
}
