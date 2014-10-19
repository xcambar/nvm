#!/usr/bin/env roundup

ENV="testing" source ./install.sh

describe "nvm_error"

it_exits_with_error_code() {
  local status=`set +e ; nvm_error "error" > /dev/null 2>&1 ; echo $?`
  test "$status" = "1"
}

it_is_the_last_command_than_can_execute() {
  local status=`nvm_error "error" > /dev/null 2>&1 ; echo "not_executed"`
  test "$status" != "not_executed"
  test "$status" = ""
}
