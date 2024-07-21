#!/bin/bash

# Colors for output
NC="\033[0m" # No Color
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

# Function to ask for user confirmation
ask() {
    local prompt=$1
    if $AUTO; then
        return 0
    fi
    while true; do
        read -p "$prompt (y/n): " answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            return 0
        elif [[ "$answer" == "n" || "$answer" == "N" ]]; then
            return 1
        else
            echo -e "${RED}Please answer y or n.${NC}"
        fi
    done
}

# Request sudo permissions at the start
request_sudo() {
    echo -e "${YELLOW}Requesting sudo permissions...${NC}"
    sudo -v
    if [ $? -ne 0 ]; then
        echo -e "${RED}Sudo permissions are required to run this script.${NC}"
        exit 1
    fi
}

# Function to check and install necessary utilities
check_and_install_utilities() {
    local missing_utils=()
    for util in ps awk grep; do
        if ! command -v $util &>/dev/null; then
            missing_utils+=($util)
        fi
    done

    if [ ${#missing_utils[@]} -ne 0 ]; then
        echo -e "${YELLOW}The following utilities are missing: ${missing_utils[*]}${NC}"
        if ask "Do you want to install them?"; then
            echo -e "${YELLOW}Installing missing utilities...${NC}"
            if command -v apt-get &>/dev/null; then
                sudo apt install -y ${missing_utils[*]} >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (apt)"
            elif command -v yum &>/dev/null; then
                sudo yum install -y ${missing_utils[*]} >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (yum)"
            elif command -v apk &>/dev/null; then
                sudo apk add ${missing_utils[*]} >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (apk)"
            elif command -v nix-env &>/dev/null; then
                nix-env -iA nixpkgs.${missing_utils[*]} >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (nix)"
            elif command -v brew &>/dev/null; then
                brew install ${missing_utils[*]} >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (brew)"
            else
                echo -e "${RED}No supported package manager found. Exiting...${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Cannot proceed without installing the necessary utilities. Exiting...${NC}"
            exit 1
        fi
    fi
}
