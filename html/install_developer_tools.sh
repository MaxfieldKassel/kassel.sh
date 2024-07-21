#!/bin/bash

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

if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos_tools
fi
