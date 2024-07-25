#!/usr/bin/env bash

COMMON_SOFTWARE="git neovim curl wget htop fzf git-lfs tree jq unzip zip"

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

# Function to install common software
install_software() {
    if command -v apt-get &>/dev/null; then
        sudo apt install -y $COMMON_SOFTWARE >"$temp_file" 2>&1 &
        spinner $! "Installing common software (apt)"
    elif command -v yum &>/dev/null; then
        sudo yum install -y $COMMON_SOFTWARE >"$temp_file" 2>&1 &
        spinner $! "Installing common software (yum)"
    elif command -v apk &>/dev/null; then
        sudo apk add $COMMON_SOFTWARE >"$temp_file" 2>&1 &
        spinner $! "Installing common software (apk)"
    elif command -v nix-env &>/dev/null; then
        nix-env -iA nixpkgs.${COMMON_SOFTWARE// / nixpkgs.} >"$temp_file" 2>&1 &
        spinner $! "Installing common software (nix)"
    elif command -v brew &>/dev/null; then
        brew install $COMMON_SOFTWARE >"$temp_file" 2>&1 &
        spinner $! "Installing common software (brew)"
    else
        log_error "No supported package manager found. Exiting..."
        exit 1
    fi
}

# Check if the script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    temp_file=$(mktemp)
    install_software
fi