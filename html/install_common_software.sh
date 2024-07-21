#!/bin/bash

COMMON_SOFTWARE="git neovim curl wget htop"

# Function to install common software
install_software() {
    echo -e "${YELLOW}Installing common software...${NC}"
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

install_software
