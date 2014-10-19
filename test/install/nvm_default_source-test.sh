#!/usr/bin/env roundup

describe "nvm_default_source";

ENV="testing" source $PWD/install.sh

it_returns_the_git_repo_when_git() {
  nvm_default_source git | head -n 1 | grep ".git$" > /dev/null
  test $? = 0
}

it_returns_a_url_to_nvm_sh_when_curl() {
  nvm_default_source curl | head -n 1 | grep "nvm.sh$" > /dev/null
  test $? = 0
}

it_returns_a_url_to_nvm_sh_when_wget() {
  nvm_default_source wget | head -n 1 | grep "nvm.sh$" > /dev/null
  test $? = 0
}

it_returns_nothing_otherwise() {
  ret=`nvm_default_source unknown`
  test -z "$ret"
}
