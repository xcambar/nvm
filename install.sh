#!/bin/bash

# 
# This script install [NVM](https://github.com/creationix/nvm)
#
# Simply run `./install.sh` to start the installation process
# 
# Execution can be customized with the following environment variables:
#
# * NVM_DIR (defaults to `$HOME/.nvm`)
# * NVM_SOURCE (the default value depends on `$METHOD`)
# * METHOD (defaults to `git`)
# * PROFILE (defaults to `$PROFILE`)
#

# Exits on errors
set -e 

#
# Checks that an executable is available
# 
nvm_has() {
  $( type "$1" > /dev/null 2>&1 )
  return $?
}

# 
# Determines a PROFILE file if not already provided
# This file will contain the init script for NVM
# 
nvm_lookup_profile() {
  local profile="$1"
  if [ -n "$profile" ]; then
    echo "$profile"
  elif [ -f "$HOME/.bashrc" ]; then
    echo "$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    echo "$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    echo "$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    echo "$HOME/.profile"
  fi
}

#
# Download NVM as a script
# works with curl and wget
# 
nvm_download() {
  local method=$1
  shift
  if [ "$method" = "curl" ]; then
    curl $*
  elif [ "$method" = "wget" ]; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    wget $ARGS
  fi
}

#
# Installs NVM with git or updates nvm if detected
#
install_nvm_from_git() {
  local source="$1"
  local dest="$2"

  if [ -d "$dest/.git" ]; then
    echo "=> nvm is already installed in $dest, trying to update"
    printf "\r=> "
    cd "$dest" && (git fetch 2> /dev/null || {
      echo >&2 "Failed to update nvm, run 'git fetch' in $dest yourself." && exit 1
    })
  else
    # Cloning to $NVM_DIR
    echo "=> Downloading nvm from git to '$dest'"
    printf "\r=> "
    mkdir -p "$dest"
    git clone "$source" "$dest"
  fi
  cd "$dest" && git checkout v0.17.2 && git branch -D master >/dev/null 2>&1
  return
}

#
# Prepares for installation as script
# 
install_nvm_as_script() {
  local method="$1"
  local source="$2"
  local dest="$3"

  mkdir -p "$dest"
  if [ -f "$dest/nvm.sh" ]; then
    echo "=> nvm is already installed in $dest, trying to update"
  else
    echo "=> Downloading nvm as script to '$dest'"
  fi
  nvm_download $method -s "$source" -o "$dest/nvm.sh" || {
    echo >&2 "Failed to download '$source'.."
    return 1
  }
}

#
# Outputs an error to stderr
# exits the current cript
#
nvm_error () {
  echo >&2 "=> $1"
  exit 1
}

#
# Checks that the selected method exists and can be executed
#
nvm_check_method() {
  local method="$1"
  local has_git=$2
  local has_curl=$3
  local has_wget=$4
  local error=""
  if [ "$method" = "git" ] && ! $has_git; then
    error="You need git to use the Git method"
  elif [ "$method" = "curl" ] && ! $has_curl; then
    error="You need curl to use the curl method"
  elif [ "$method" = "wget" ] && ! $has_wget; then
    error="You need wget to use the wget method"
  elif [ "$method" != "git" ] && [ "$method" != "curl" ] && [ "$method" != "wget" ]; then
    error="Unknown install method $method"
  fi
  if [ -n "$error" ]; then
    nvm_error "$error"
  fi
  return 0
}

#
# Returns the default location for the selected method
#
nvm_default_source() {
  local method="$1"
  if [ "$method" = "git" ]; then
    echo "https://github.com/creationix/nvm.git"
  elif [ "$method" = "curl" ] || [ "$method" = "wget" ]; then
    echo "https://raw.githubusercontent.com/creationix/nvm/v0.17.2/nvm.sh"
  fi
}

#
# Starts the installation process based on the selected method
#
nvm_install_with_method() {
  local method="$1"
  local source="$2"
  local dest="$3"
  if [ "$method" = "git" ]; then
    install_nvm_from_git "$source" "$dest"
  elif [ "$method" = "curl" ] || [ "$method" = "wget" ]; then
    install_nvm_as_script "$method" "$source" "$dest"
  fi
}

#
# Display a message when the PROFILE has not been found
#
nvm_manual_profile_update_msg() {
  local script="$1"
  echo "=> Profile not found. Tried \$PROFILE, ~/.bashrc, ~/.bash_profile, ~/.zshrc, and ~/.profile."
  echo "=> You can do either of the following:"
  echo "    * Create the startup script corresponding to your shell and run this script again,"
  echo "    * Append the following lines to your shell's startup script:"
  echo
  printf "$script"
  echo
}

#
# Automatically updates the user's profile
#
nvm_auto_profile_update() {
  local dest="$1"
  local script="$2"
  if ! grep -qc 'nvm.sh' "$dest"; then
    echo "=> Appending source string to $dest"
    printf "$script\n" >> "$dest"
  else
    echo "=> Source string already in $script"
  fi
}

#
# Decides whether to do an automatic update of the profile
# or if the user needs to do it
#
nvm_update_profile() {
  local profile="$1"
  local nvm_dir="$2"
  local source="\nexport NVM_DIR=\"$nvm_dir\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm"

  if [ -z "$profile" ] || [ ! -f "$profile" ] ; then
    nvm_manual_profile_update_msg "$source"
  else
    nvm_auto_profile_update "$profile" "$source"
  fi
}

#
# Selects the method by availability
# Selected in this order: git > curl > wget
#
nvm_method_name() {
  local has_git=$1
  local has_curl=$2
  local has_wget=$3
  if $has_git; then
    echo "git"
  elif $has_curl; then
    echo "curl"
  elif $has_wget; then
    echo "wget"
  fi
}

#
# Checks that at least one of the valid methods are available
# and checks that the selected one can be used
#
nvm_setup_method() {
  local method="$1"
  local git
  local curl
  local wget
  nvm_has git && git=true || git=false
  nvm_has curl && curl=true || curl=false
  nvm_has wget && wget=true || wget=false

  if ! $git && ! $curl && ! $wget; then
    nvm_error "You need git, curl, or wget to install nvm"
  fi
  : ${method:=$(nvm_method_name $git $curl $wget)}
  nvm_check_method "$method" $git $curl $wget
  echo $method
}

#
# Start the actual install process
#
nvm_run_install() {
  method=$(nvm_setup_method "$METHOD")
  profile=$(nvm_lookup_profile "$PROFILE")
  : ${NVM_DIR:="$HOME/.nvm"}
  : ${NVM_SOURCE:=$(nvm_default_source $method)}

  nvm_install_with_method "$method" "$NVM_SOURCE" "$NVM_DIR"
  nvm_update_profile "$profile" "$NVM_DIR"

  source "$NVM_DIR/nvm.sh"
  echo "=> Installation successful."
}

if [ "$ENV" != "testing" ]; then 
  nvm_run_install
fi
