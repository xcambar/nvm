#!/usr/bin/env roundup

describe "nvm_check_method"

before() {
  ENV="testing" source ./install.sh
}

it_succeeds_if_git_is_selected_and_available() {
  nvm_check_method "git" true false false
  test $? = 0
}

it_succeeds_if_curl_is_selected_and_available() {
  nvm_check_method "curl" false true false
  test $? = 0
}

it_succeeds_if_wget_is_selected_and_available() {
  nvm_check_method "wget" false false true
  test $? = 0
}

it_fails_if_the_method_is_unknown() {
  local nvm_error_called
  nvm_error() {
    nvm_error_called=true
  }
  nvm_check_method "unknown_method" true true true
  test $nvm_error_called
}

it_fails_if_git_is_selected_but_not_available() {
  local nvm_error_called
  nvm_error() {
    nvm_error_called=true
  }
  nvm_check_method "git" false false false
  test $nvm_error_called
}

it_fails_if_curl_is_selected_but_not_available() {
  local nvm_error_called
  nvm_error() {
    nvm_error_called=true
  }
  nvm_check_method "curl" false false false
  test $nvm_error_called
}

it_fails_if_wget_is_selected_but_not_available() {
  local nvm_error_called
  nvm_error() {
    nvm_error_called=true
  }
  nvm_check_method "wget" false false false
  test $nvm_error_called
}

