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
    local spinstr='/-\|'
    echo -ne "${YELLOW}${text}... ${NC}"
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    wait $pid
    local status=$?
    printf "    \b\b\b\b"
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}Done!${NC}"
    else
        echo -e "${RED}Fail!${NC}"
    fi
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

# Request sudo permissions at the start
echo -e "${YELLOW}Requesting sudo permissions...${NC}"
sudo -v
if [ $? -ne 0 ]; then
    echo -e "${RED}Sudo permissions are required to run this script.${NC}"
    exit 1
fi

# Function to install oh-my-zsh
install_oh_my_zsh() {
    echo -e "${YELLOW}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-zsh"
}

# Function to install oh-my-bash
install_oh_my_bash() {
    echo -e "${YELLOW}Installing oh-my-bash...${NC}"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-bash"
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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing Homebrew"
    fi
}

# Function to update package lists
update_package_lists() {
    echo -e "${YELLOW}Updating package lists...${NC}"
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
    echo -e "${YELLOW}Upgrading packages...${NC}"
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

# Function to install Nerd Fonts
install_nerd_fonts() {
    echo -e "${YELLOW}Installing Nerd Fonts...${NC}"
    git clone --depth 1 -b master https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts >"$temp_file" 2>&1 &
    spinner $! "Cloning Nerd Fonts"
    /tmp/nerd-fonts/install.sh inconsolata >"$temp_file" 2>&1 &
    spinner $! "Installing Inconsolata Nerd Fonts"
    rm -rf /tmp/nerd-fonts
}

# Function to set Nerd Fonts for the terminal
set_nerd_fonts_terminal() {
    echo -e "${YELLOW}Setting Nerd Fonts for the terminal...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        defaults write com.apple.Terminal "Default Window Settings" -string "NerdFonts"
        defaults write com.apple.Terminal "Startup Window Settings" -string "NerdFonts"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
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
check_and_install_utilities

# Update package lists
update_package_lists

# Ask for upgrade
if ask "Do you want to upgrade all packages?"; then
    upgrade_packages
fi

# Install developer tools and Homebrew on macOS if needed
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos_tools
fi

# Detect current shell
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
    install_oh_my_zsh
elif [[ "$current_shell" == "bash" ]]; then
    install_oh_my_bash
else
    echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
    rm "$temp_file"
    exit 1
fi

# Install common software
install_software

# Install Nerd Fonts and set for terminal
install_nerd_fonts
set_nerd_fonts_terminal

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Setup complete!${NC}"
    rm "$temp_file"
else
    echo -e "${RED}An error occurred. Check the log file for details: $temp_file${NC}"
fi