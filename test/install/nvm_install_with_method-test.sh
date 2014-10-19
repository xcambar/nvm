#!/usr/bin/env roundup

describe 'nvm_install_with_mithod'

before() {
  ENV="testing" source $PWD/install.sh
}

it_should_call_the_git_installer_when_method_is_git() {
  installer_called=false
  install_nvm_from_git() {
    installer_called=true
    installer_source=$1
    installer_dest=$2
  }
  nvm_install_with_method git _source_ _dest_
  test installer_called
  test "$installer_source" = "_source_"
  test "$installer_dest" = "_dest_"
}

it_should_call_the_script_installer_when_method_is_curl() {
  installer_called=false
  install_nvm_as_script() {
    installer_called=true
    installer_method=$1
    installer_source=$2
    installer_dest=$3
  }
  nvm_install_with_method curl _source_ _dest_
  test installer_called
  test "$installer_method" = "curl"
  test "$installer_source" = "_source_"
  test "$installer_dest" = "_dest_"
}

it_should_call_the_script_installer_when_method_is_wget() {
  installer_called=false
  install_nvm_as_script() {
    installer_called=true
    installer_method=$1
    installer_source=$2
    installer_dest=$3
  }
  nvm_install_with_method wget _source_ _dest_
  test installer_called
  test "$installer_method" = "wget"
  test "$installer_source" = "_source_"
  test "$installer_dest" = "_dest_"
}

it_should_call_no_installer_otherwise() {
  installer_called=false
  install_nvm_as_script() {
    installer_called=true
  }
  install_nvm_from_git() {
    installer_called=true
  }
  nvm_install_with_method unkmown_method
  test !$installer_called
}
