#!/usr/bin/env bash

# Function to update package lists
update_package_lists() {
    echo -e "${CYAN}Updating package lists...${NC}"
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
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
}

# Function to upgrade packages
upgrade_packages() {
    echo -e "${CYAN}Upgrading packages...${NC}"
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
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    update_package_lists

    if ask "Do you want to upgrade all packages?"; then
        upgrade_packages
    fi
fi
