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
  test $(nvm_lookup_profile "__file__") = "__file__"
}

it_selects_bashrc_if_it_exists_and_no_argument_is_provided() {
  test $(nvm_lookup_profile) = "./.bashrc"
}

it_otherwise_selects_bash_profile() {
  rm -f .bashrc
  test $(nvm_lookup_profile) = "./.bash_profile"
}

it_otherwise_selects_zshrc() {
  rm -f .bashrc .bash_profile
  test $(nvm_lookup_profile) = "./.zshrc"
}

it_otherwise_selects_profile() {
  rm -f .bashrc .bash_profile .zshrc
  test $(nvm_lookup_profile) = "./.profile"
}

it_otherwise_returns_an_empty_string() {
  rm -f .bashrc .bash_profile .zshrc .profile
  test -z $(nvm_lookup_profile)
}

