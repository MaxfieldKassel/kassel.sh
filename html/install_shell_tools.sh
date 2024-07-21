#!/bin/bash

# Function to install oh-my-zsh
install_oh_my_zsh() {
    echo -e "${CYAN}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-zsh"
}

# Function to install oh-my-bash
install_oh_my_bash() {
    echo -e "${CYAN}Installing oh-my-bash...${NC}"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" >"$temp_file" 2>&1 &
    spinner $! "Installing oh-my-bash"
}

# Detect current shell
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
    install_oh_my_zsh
elif [[ "$current_shell" == "bash" ]]; then
    install_oh_my_bash
else
    echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
    exit 1
fi
