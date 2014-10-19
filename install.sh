#!/bin/bash

set -e 

nvm_has() {
  type "$1" > /dev/null 2>&1
  echo $?
}

# Detect profile file if not specified as environment variable (eg: PROFILE=~/.myprofile).
nvm_lookup_profile() {
  if [ -f "$HOME/.bashrc" ]; then
    echo "$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    echo "$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    echo "$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    echo "$HOME/.profile"
  fi
}

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

nvm_error () {
  echo >&2 "=> $1"
  exit 1
}

# Checks that the selected method exists
# and s available
# Helps when the user specifies the method
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

nvm_default_source() {
  local method="$1"
  if [ "$method" = "git" ]; then
    echo "https://github.com/creationix/nvm.git"
  elif [ "$method" = "script" ]; then
    echo "https://raw.githubusercontent.com/creationix/nvm/v0.17.2/nvm.sh"
  fi
}

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

nvm_manual_profile_update_msg() {
  local script="$1"
  echo "=> Profile not found. Tried \$PROFILE, ~/.bashrc, ~/.bash_profile, ~/.zshrc, and ~/.profile."
  echo "=> You can do either of the following:"
  echo "    * Create the startup script corresponding to your shell and run this script again,"
  echo "    * Append the following lines to your shell's startup script:"
  echo
  printf "$startup_script"
  echo
}

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

nvm_update_profile() {
  local profile="$1"
  local nvm_dir="$2"
  local source="\nexport NVM_DIR=\"$nvm_dir\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm"
  : ${profile:=$(nvm_lookup_profile)}


  if [ -z "$profile" ] || [ ! -f "$profile" ] ; then
    nvm_manual_profile_update_msg "$source"
  else
    nvm_auto_profile_update "$profile" "$source"
  fi
}

# Autodetect install method
nvm_method_name() {
  local git=$1
  local curl=$2
  local wget=$3
  if $git; then
    echo "git"
  elif $curl; then
    echo "curl"
  elif $wget; then
    echo "wget"
  fi
}

nvm_setup_method() {
  local method="$1"
  local git="$2"
  local curl="$3"
  local wget="$4"
  if ! [ -z $curl ]; then curl=true; else curl=false; fi
  if ! [ -z $wget ]; then wget=true; else wget=false; fi
  if ! [ -z $git ]; then git=true; else git=false; fi

  if ! $git && ! $curl && ! $wget; then
    nvm_error "You need git, curl, or wget to install nvm"
  fi
  : ${method:=$(nvm_method_name $git $curl $wget)}
  nvm_check_method "$method" $git $curl $wget
  echo $method
}


# Environment variables:
# NVM_DIR
# NVM_SOURCE
# METHOD
# PROFILE
method=$(nvm_setup_method "$METHOD" $(nvm_has "git") $(nvm_has "curl") $(nvm_has "wget"))
: ${NVM_DIR:="$HOME/.nvm"}
: ${NVM_SOURCE:=$(nvm_default_source $method)}

nvm_install_with_method "$method" "$NVM_SOURCE" "$NVM_DIR"
nvm_update_profile "$PROFILE" "$NVM_DIR"

source "$NVM_DIR/nvm.sh"
echo "=> Installation successful."

