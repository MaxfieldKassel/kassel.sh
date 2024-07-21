#!/usr/bin/env bash

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    source <(curl -s "https://kassel.sh/utils.sh")
fi

# Function to install developer tools and Homebrew on macOS
install_macos_tools() {
    echo -e "${CYAN}Checking for Xcode command line tools...${NC}"
    if ! xcode-select -p &>/dev/null; then
        echo -e "${CYAN}Installing Xcode command line tools...${NC}"
        xcode-select --install
        while ! xcode-select -p &>/dev/null; do
            sleep 5
        done
    fi

    echo -e "${CYAN}Checking for Homebrew...${NC}"
    if ! command -v brew &>/dev/null; then
        echo -e "${CYAN}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing Homebrew"
    fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos_tools
fi
