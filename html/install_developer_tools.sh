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

# Function to install developer tools and Homebrew on macOS
install_macos_tools() {
    log_info "Checking for Xcode command line tools..."
    if ! xcode-select -p &>/dev/null; then
        (xcode-select --install &)
        spinner_pid=$!
        while ! xcode-select -p &>/dev/null; do
            sleep 5
        done &
        spinner $spinner_pid "Installing Xcode command line tools"
    else
        log_info "Xcode command line tools already installed."
    fi

    log_info "Checking for Homebrew..."
    if ! command -v brew &>/dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing Homebrew"

        # Adding Homebrew to ~/.bashrc
        log_info "Adding Homebrew to ~/.bashrc..."
        {
            echo ''
            echo '# Set PATH, MANPATH, etc., for Homebrew.'
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >>~/.bashrc

        log_info "Adding Homebrew to ~/.zshrc..."
        {
            echo ''
            echo '# Set PATH, MANPATH, etc., for Homebrew.'
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >>~/.zshrc

        # Source ~/.bashrc
        log_info "Sourcing ~/.bashrc..."
        source ~/.bashrc

    else
        log_info "Homebrew already installed."
    fi
}

# Check if the script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_macos_tools
    fi
fi
