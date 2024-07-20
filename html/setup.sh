#!/bin/bash

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Common software list
COMMON_SOFTWARE="git neovim curl wget htop"

# Function to show a loading spinner with custom text
spinner() {
    local pid=$1
    local text=$2
    local delay=0.1
    local spinstr='/-\-|'
    echo -ne "${YELLOW}${text}... ${NC}"
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
    echo -e "${GREEN}Done!${NC}"
}

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

# Function to install oh-my-zsh
install_oh_my_zsh() {
    echo -e "${YELLOW}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Function to install oh-my-bash
install_oh_my_bash() {
    echo -e "${YELLOW}Installing oh-my-bash...${NC}"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
}

# Function to install developer tools and Homebrew on macOS
install_macos_tools() {
    echo -e "${YELLOW}Checking for Xcode command line tools...${NC}"
    if ! xcode-select -p &>/dev/null; then
        echo -e "${YELLOW}Installing Xcode command line tools...${NC}"
        xcode-select --install
        while ! xcode-select -p &>/dev/null; do
            sleep 5
        done
    fi

    echo -e "${YELLOW}Checking for Homebrew...${NC}"
    if ! command -v brew &>/dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to update package lists and ask for upgrade
update_and_upgrade() {
    echo -e "${YELLOW}Updating package lists...${NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt update
        if ask "Do you want to upgrade all packages?"; then
            sudo apt upgrade -y
        fi
    elif command -v yum &>/dev/null; then
        sudo yum update -y
        if ask "Do you want to upgrade all packages?"; then
            sudo yum upgrade -y
        fi
    elif command -v apk &>/dev/null; then
        sudo apk update
        if ask "Do you want to upgrade all packages?"; then
            sudo apk upgrade
        fi
    elif command -v nix-env &>/dev/null; then
        nix-channel --update
        if ask "Do you want to upgrade all packages?"; then
            nix-env -u
        fi
    elif command -v brew &>/dev/null; then
        brew update
        if ask "Do you want to upgrade all packages?"; then
            brew upgrade
        fi
    else
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
}

# Function to install common software
install_software() {
    echo -e "${YELLOW}Installing common software...${NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt install -y $COMMON_SOFTWARE
    elif command -v yum &>/dev/null; then
        sudo yum install -y $COMMON_SOFTWARE
    elif command -v apk &>/dev/null; then
        sudo apk add $COMMON_SOFTWARE
    elif command -v nix-env &>/dev/null; then
        nix-env -iA nixpkgs.${COMMON_SOFTWARE// / nixpkgs.}
    elif command -v brew &>/dev/null; then
        brew install $COMMON_SOFTWARE
    else
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
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
            if command -v apt-get &>/dev/null; then
                sudo apt install -y ${missing_utils[*]}
            elif command -v yum &>/dev/null; then
                sudo yum install -y ${missing_utils[*]}
            elif command -v apk &>/dev/null; then
                sudo apk add ${missing_utils[*]}
            elif command -v nix-env &>/dev/null; then
                nix-env -iA nixpkgs.${missing_utils[*]}
            elif command -v brew &>/dev/null; then
                brew install ${missing_utils[*]}
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

# Main script
AUTO=false
while getopts ":a" opt; do
  case $opt in
    a)
      AUTO=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Create a temporary file for command output
temp_file=$(mktemp)

# Check and install necessary utilities
check_and_install_utilities >"$temp_file" 2>&1 &
spinner $! "Checking and installing necessary utilities"

# Update package lists and ask for upgrade
update_and_upgrade >"$temp_file" 2>&1 &
spinner $! "Updating package lists"

# Install developer tools and Homebrew on macOS if needed
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos_tools >"$temp_file" 2>&1 &
    spinner $! "Installing developer tools and Homebrew"
fi

# Detect current shell
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
    install_oh_my_zsh >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-zsh"
elif [[ "$current_shell" == "bash" ]]; then
    install_oh_my_bash >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-bash"
else
    echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
    rm "$temp_file"
    exit 1
fi

# Install common software
install_software >"$temp_file" 2>&1 &
spinner $! "Installing common software"

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Setup complete!${NC}"
    rm "$temp_file"
else
    echo -e "${RED}An error occurred. Check the log file for details: $temp_file${NC}"
fi
