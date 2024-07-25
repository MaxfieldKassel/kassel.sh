#!/usr/bin/env bash

# Function to update package lists
update_package_lists() {
    log_debug "Starting update_package_lists function"
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

# Function to count packages needing an upgrade
count_upgradable_packages() {
    log_debug "Starting count_upgradable_packages function"
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
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
    log_debug "Upgradable packages count: $count"
    echo "$count"
}

# Function to upgrade packages
upgrade_packages() {
    log_debug "Starting upgrade_packages function"
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

update_and_upgrade() {
    log_debug "Starting update_and_upgrade function"
    update_package_lists

    package_count=$(count_upgradable_packages)
    if [[ "$package_count" -eq 0 ]]; then
        echo -e "${CYAN}No packages to upgrade.${NC}"
    else
        echo -e "${CYAN}$package_count packages need upgrading.${NC}"
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
