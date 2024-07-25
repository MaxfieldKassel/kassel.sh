#!/usr/bin/env bash

BASE_URL="https://kassel.sh"

# Function to download and source a script
download_and_source_script() {
  local script_name=$1
  local temp_script=$(mktemp)
  curl -s "$BASE_URL/$script_name" -o "$temp_script"
  if [ $? -ne 0 ]; then
    log_error "Failed to download $script_name. Exiting..."
    rm "$temp_script"
    exit 1
  fi
  source "$temp_script"
  if [ $? -ne 0 ]; then
    log_error "Failed to source $script_name. Exiting..."
    rm "$temp_script"
    exit 1
  fi
  rm "$temp_script"
  log_debug "Downloaded and sourced $script_name"
}

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    download_and_source_script "utils.sh"
fi

# Function to update package lists
update_package_lists() {
    log_debug "Starting update_package_lists function"
    log_info "Updating package lists..."
    if command -v apt-get &>/dev/null; then
        sudo apt update >"$temp_file" 2>&1 &
        spinner $! "Updating package lists (apt)"
    elif command -v yum &>/dev/null; then
        sudo yum update -y >"$temp_file" 2>&1 &
        spinner $! "Updating package lists (yum)"
    elif command -v apk &>/dev/null; then
        sudo apk update >"$temp_file" 2>&1 &
        spinner $! "Updating package lists (apk)"
    elif command -v nix-env &>/dev/null; then
        nix-channel --update >"$temp_file" 2>&1 &
        spinner $! "Updating package lists (nix)"
    elif command -v brew &>/dev/null; then
        brew update >"$temp_file" 2>&1 &
        spinner $! "Updating package lists (brew)"
    else
        log_error "No supported package manager found. Exiting..."
        exit 1
    fi
}

# Function to count packages needing an upgrade
count_upgradable_packages() {
    log_debug "Starting count_upgradable_packages function"
    local count=0
    if command -v apt-get &>/dev/null; then
        count=$(apt list --upgradable 2>/dev/null | grep -c 'upgradable')
    elif command -v yum &>/dev/null; then
        count=$(yum check-update 2>/dev/null | grep -c '^')
    elif command -v apk &>/dev/null; then
        count=$(apk version -l '<' | grep -c 'L')
    elif command -v nix-env &>/dev/null; then
        count=$(nix-env -u --dry-run 2>&1 | grep -c 'would be upgraded')
    elif command -v brew &>/dev/null; then
        count=$(brew outdated | wc -l)
    else
        log_error "No supported package manager found. Exiting..."
        exit 1
    fi
    log_debug "Upgradable packages count: $count"
    return $count
}

# Function to upgrade packages
upgrade_packages() {
    log_debug "Starting upgrade_packages function"
    log_info "Upgrading packages..."
    if command -v apt-get &>/dev/null; then
        sudo apt upgrade -y >"$temp_file" 2>&1 &
        spinner $! "Upgrading packages (apt)"
    elif command -v yum &>/dev/null; then
        sudo yum upgrade -y >"$temp_file" 2>&1 &
        spinner $! "Upgrading packages (yum)"
    elif command -v apk &>/dev/null; then
        sudo apk upgrade >"$temp_file" 2>&1 &
        spinner $! "Upgrading packages (apk)"
    elif command -v nix-env &>/dev/null; then
        nix-env -u >"$temp_file" 2>&1 &
        spinner $! "Upgrading packages (nix)"
    elif command -v brew &>/dev/null; then
        brew upgrade >"$temp_file" 2>&1 &
        spinner $! "Upgrading packages (brew)"
    else
        log_error "No supported package manager found. Exiting..."
        exit 1
    fi
}

update_and_upgrade() {
    log_debug "Starting update_and_upgrade function"
    update_package_lists

    count_upgradable_packages
    package_count=$?
    if [[ "$package_count" -eq 0 ]]; then
        log_info "No packages to upgrade."
    else
        log_info "$package_count packages need upgrading."
        if ask "Do you want to upgrade all packages?"; then
            upgrade_packages
        fi
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    DEBUG=false
    # Temporary file for command output
    temp_file=$(mktemp)

    update_and_upgrade

    # Clean up temporary file
    rm -f "$temp_file"
fi