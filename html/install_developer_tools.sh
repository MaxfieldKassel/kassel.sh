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
    else
        echo -e "${CYAN}Xcode command line tools already installed.${NC}"
    fi

    echo -e "${CYAN}Checking for Homebrew...${NC}"
    if ! command -v brew &>/dev/null; then
        echo -e "${CYAN}Installing Homebrew...${NC}"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing Homebrew"

        # Adding Homebrew to ~/.bashrc
        echo -e "${CYAN}Adding Homebrew to ~/.bashrc...${NC}"
        {
            echo ''
            echo '# Set PATH, MANPATH, etc., for Homebrew.'
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >>~/.bashrc

        echo -e "${CYAN}Adding Homebrew to ~/.zshrc...${NC}"
        {
            echo ''
            echo '# Set PATH, MANPATH, etc., for Homebrew.'
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >>~/.zshrc

        # Source ~/.bashrc
        echo -e "${CYAN}Sourcing ~/.bashrc...${NC}"
        source ~/.bashrc

    else
        echo -e "${CYAN}Homebrew already installed.${NC}"
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_macos_tools
    fi
fi
