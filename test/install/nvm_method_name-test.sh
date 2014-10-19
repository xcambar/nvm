#!/usr.bin/env roundup

ENV="testing" source $PWD/install.sh

describe "nvm_method_name"

it_should_prefer_git() {
  test `nvm_method_name true true true | grep git`
}

it_should_fallback_to_curl() {
  test `nvm_method_name false true true | grep curl`
}

it_should_select_wget_in_last_resort() {
  test `nvm_method_name false false true | grep wget`
}

it_should_return_nothing_if_none_available() {
  test !`nvm_method_name false false false | grep "..*"`
}
