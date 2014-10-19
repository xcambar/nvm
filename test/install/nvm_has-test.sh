#!/usr/bin/env roundup

ENV="testing" source ./install.sh

describe "nvm_has"

it_succeeds_when_executable_exists() {
  local code
  nvm_has ls && code="OK_$?" || code="KO_$?"; 
  test "$code" = "OK_0"
}

it_fails_when_executable_doesnt_exist() {
  local code
  $( nvm_has doesnt_exist ) && code="OK_$?" || code="KO_$?"; 
  test "$code" = "KO_1"
}
