#!/bin/bash
#
# This script can be used to install Fail2ban and its dependencies. This script
# has been tested with Ubuntu 16.04.
#
set -e

readonly EMPTY_VAL="__EMPTY__"

readonly DEFAULT_INSTALL_PATH="/opt/fail2ban"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SYSTEM_BIN_DIR="/usr/local/bin"

readonly SCRIPT_NAME="$(basename "$0")"

function print_usage {
  echo
  echo "Usage: install-fail2ban [OPTIONS]"
  echo
  echo "This script can be used to install Fail2ban and its dependencies. This script has been tested with Ubuntu 16.04."
  echo
  echo "Example:"
  echo
  echo "  install-fail2ban"
}

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$message"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function has_apt_get {
  [[ -n "$(command -v apt-get)" ]]
}

function install_dependencies {
  log_info "Installing dependencies"

  if $(has_apt_get); then
    sudo apt-get update -y
    sudo apt-get install -y fail2ban
  else
    log_error "Could not find apt-get. Cannot install dependencies on this OS."
    exit 1
  fi
}

function user_exists {
  local readonly username="$1"

  log_info "Checking if user $username exists"
  id "$username" >/dev/null 2>&1
}

function create_fail2ban_user {
  local readonly username="$1"

  if $(user_exists "$username"); then
    log_info "User $username already exists. Will not create again."
  else
    log_info "Creating user named $username"
    sudo useradd "$username"
  fi
}

function install {

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --help)
        print_usage
        exit
        ;;
      *)
        # do nothing
        ;;
    esac

    shift
  done

  install_dependencies
  #create_fail2ban_user "$user"

  if command -v fail2ban-client; then
    log_info "Fail2ban install complete!"
  else
    log_info "Could not find Fail2ban command. Aborting.";
    exit 1;
  fi
}

install "$@"
