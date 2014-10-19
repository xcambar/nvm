#!/usr/bin/env roundup

ENV="testing" source ./install.sh

describe "nvm_has"

it_returns_an_empty_string_when_executable_exists() {
  local ret=$(nvm_has doesnt_exist)
  test -z "$ret"
}

it_returns_a_non_empry_string_when_executable_doesnt_exist() {
  local ret=$(nvm_has ls)
  test -n "$ret"
}
