#!/usr/bin/env bash

# Colors for output
NC="\033[0m" # No Color
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"

# Function to log debug messages
log_debug() {
    if [[ $DEBUG == true ]]; then
        echo -e "${YELLOW}[DEBUG] $1${NC}"
    fi
}

# Function to log error messages
log_error() {
    echo -e "${RED}$1${NC}"
}

# Function to log info messages
log_info() {
    echo -e "${CYAN}    $1${NC}"
}

# Function to log success messages
log_success() {
    echo -e "${GREEN}    $1${NC}"
}

# Function to print messages (used when needing user input)
print_message() {
    echo -e "${BLUE}$1${NC}"
}

# Function to ask for user confirmation
ask() {
    local prompt="$1"
    if [[ $AUTO == true ]]; then
        return 0
    fi
    while true; do
        print_message "$prompt (y/n): "
        read -r answer
        case "$answer" in
        [yY]) return 0 ;;
        [nN]) return 1 ;;
        *) log_error "Please answer y or n." ;;
        esac
    done
}

# Function to show a loading spinner with custom text
spinner() {
    local pid=$1
    local text=$2
    local delay=0.1
    local spinstr='|/-\'
    printf " [ ] ${text}... "
    while ps -p $pid >/dev/null; do
        local temp=${spinstr#?}
        printf "\r [%c] ${text}... " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    wait $pid
    local status=$?
    if [ $status -eq 0 ]; then
        printf "\r [\e[32m✔\e[0m] ${text}...\n"
    else
        printf "\r [\e[31m✖\e[0m] ${text}...\n"
    fi
}

# Request sudo permissions at the start
request_sudo() {
    print_message "Requesting sudo permissions..."
    sudo -v
    if [ $? -ne 0 ]; then
        log_error "Sudo permissions are required to run this script."
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
        print_message "The following utilities are missing: ${missing_utils[*]}"
        if ask "Do you want to install them?"; then
            log_info "Installing missing utilities..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y "${missing_utils[@]}" >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (apt)"
            elif command -v yum &>/dev/null; then
                sudo yum install -y "${missing_utils[@]}" >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (yum)"
            elif command -v apk &>/dev/null; then
                sudo apk add "${missing_utils[@]}" >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (apk)"
            elif command -v nix-env &>/dev/null; then
                nix-env -iA nixpkgs."${missing_utils[@]}" >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (nix)"
            elif command -v brew &>/dev/null; then
                brew install "${missing_utils[@]}" >"$temp_file" 2>&1 &
                spinner $! "Installing missing utilities (brew)"
            else
                log_error "No supported package manager found. Exiting..."
                exit 1
            fi
        else
            log_error "Cannot proceed without installing the necessary utilities. Exiting..."
            exit 1
        fi
    fi
}

# Function to check if the environment is headless
is_headless() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        return 0
    elif [[ -z "$DISPLAY" ]] && ! command -v gnome-terminal &>/dev/null && ! command -v dconf &>/dev/null; then
        return 1
    else
        return 0
    fi
}
