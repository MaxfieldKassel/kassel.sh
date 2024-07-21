#!/usr/bin/env bash

COMMON_SOFTWARE="git neovim curl wget htop"

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    source <(curl -s "https://kassel.sh/utils.sh")
fi

# Function to install common software
install_software() {
    echo -e "${CYAN}Installing common software...${NC}"
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
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_software
fi
