#!/usr/bin/env roundup

ENV="testing" source ./install.sh

describe "nvm_lookup_profile"

before() {
  _HOME=$HOME
  HOME="."
  touch .bashrc .bash_profile .zshrc .profile
}

after() {
  HOME="$_HOME"
  rm -f .bashrc .bash_profile .zshrc .profile
}

it_returns_the_first_argument() {
  local ret=$(nvm_lookup_profile "__file__")
  test "$ret" = "__file__"
}

it_selects_bashrc_if_it_exists_and_no_argument_is_provided() {
  local ret=$(nvm_lookup_profile)
  test "$ret" = "./.bashrc"
}

it_otherwise_selects_bash_profile() {
  rm -f .bashrc
  local ret=$(nvm_lookup_profile)
  test "$ret" = "./.bash_profile"
}

it_otherwise_selects_zshrc() {
  rm -f .bashrc .bash_profile
  local ret=$(nvm_lookup_profile)
  test "$ret" = "./.zshrc"
}

it_otherwise_selects_profile() {
  rm -f .bashrc .bash_profile .zshrc
  local ret=$(nvm_lookup_profile)
  test "$ret" = "./.profile"
}

it_otherwise_returns_an_empty_string() {
  rm -f .bashrc .bash_profile .zshrc .profile
  local ret=$(nvm_lookup_profile)
  test -z "$ret"
}

