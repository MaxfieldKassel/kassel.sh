#!/usr/bin/env bash

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    source <(curl -s "https://kassel.sh/utils.sh")
fi

# Function to install zsh-autosuggestions
install_zsh_autosuggestions() {
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        echo -e "${CYAN}zsh-autosuggestions is already installed.${NC}"
    else
        echo -e "${CYAN}Installing zsh-autosuggestions...${NC}"
        git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions >"$temp_file" 2>&1 &
        spinner $! "Installing zsh-autosuggestions"
    fi
}

# Function to install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        echo -e "${CYAN}zsh-syntax-highlighting is already installed.${NC}"
    else
        echo -e "${CYAN}Installing zsh-syntax-highlighting...${NC}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting >"$temp_file" 2>&1 &
        spinner $! "Installing zsh-syntax-highlighting"
    fi
}

# Function to install Powerlevel10k
install_powerlevel10k() {
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo -e "${CYAN}Powerlevel10k is already installed.${NC}"
    else
        echo -e "${CYAN}Installing Powerlevel10k...${NC}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k >"$temp_file" 2>&1 &
        spinner $! "Installing Powerlevel10k"
    fi
    if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
        echo -e "${CYAN}Enabled Powerlevel10k theme for oh-my-zsh.${NC}"
    else
        echo -e "${CYAN}Powerlevel10k theme is already enabled.${NC}"
    fi
}

# Function to install oh-my-zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${CYAN}oh-my-zsh is already installed.${NC}"
    else
        echo -e "${CYAN}Installing oh-my-zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing oh-my-zsh"
    fi

    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
    install_powerlevel10k

    if grep -q "plugins=(git)" "$HOME/.zshrc"; then
        if ask "Configuration for git plugin already exists. Do you want to back it up?"; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
            echo -e "${CYAN}Backup created at $HOME/.zshrc.bak.${NC}"
        fi
    fi
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        echo -e "${CYAN}Enabled git, zsh-autosuggestions, and zsh-syntax-highlighting plugins for oh-my-zsh.${NC}"
    else
        echo -e "${CYAN}Plugins already configured in .zshrc.${NC}"
    fi
}

# Function to install bash-completion
install_bash_completion() {
    if ! dpkg -l | grep -qw bash-completion; then
        echo -e "${CYAN}Installing bash-completion...${NC}"
        sudo apt-get install -y bash-completion >"$temp_file" 2>&1 &
        spinner $! "Installing bash-completion"
    else
        echo -e "${CYAN}bash-completion is already installed.${NC}"
    fi
}

# Function to install grc using the automated script
install_grc() {
    if ! command -v grc &>/dev/null; then
        echo -e "${CYAN}Installing grc...${NC}"
        bash -c "$(curl -fsSL https://github.com/garabik/grc/raw/master/grc.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing grc"
    else
        echo -e "${CYAN}grc is already installed.${NC}"
        return 0
    fi

    # Download grc.sh for alias definitions
    curl -fsSL https://github.com/garabik/grc/raw/master/grc.sh -o "$HOME/.grc.sh" >"$temp_file" 2>&1 &
    spinner $! "Downloading grc.sh"

    if ! grep -q "source $HOME/.grc.sh" "$HOME/.bashrc"; then
        echo 'export GRC_ALIASES=true' >> "$HOME/.bashrc"
        echo "source $HOME/.grc.sh" >> "$HOME/.bashrc"
    fi
}

# Function to configure Powerbash10k for Oh-My-Bash
configure_powerbash10k() {
    if ! grep -q 'OSH_THEME="powerbash10k/powerbash10k"' "$HOME/.bashrc"; then
        echo -e "${CYAN}Configuring Powerbash10k theme for Oh-My-Bash...${NC}"
        sed -i 's|OSH_THEME=".*"|OSH_THEME="powerbash10k/powerbash10k"|' "$HOME/.bashrc"
        echo -e "${CYAN}Enabled Powerbash10k theme for Oh-My-Bash.${NC}"
    else
        echo -e "${CYAN}Powerbash10k theme is already enabled.${NC}"
    fi
}

# Function to install oh-my-bash
install_oh_my_bash() {
    if [ -d "$HOME/.oh-my-bash" ]; then
        echo -e "${CYAN}oh-my-bash is already installed.${NC}"
    else
        echo -e "${CYAN}Installing oh-my-bash...${NC}"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing oh-my-bash"
    fi

    install_bash_completion
    install_grc
    configure_powerbash10k

    if grep -q "source /usr/share/bash-completion/bash_completion" "$HOME/.bashrc"; then
        if ask "Configuration for bash-completion already exists. Do you want to back it up?"; then
            cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
            echo -e "${CYAN}Backup created at $HOME/.bashrc.bak.${NC}"
        fi
    fi

    if ! grep -q "bash_completion" "$HOME/.bashrc"; then
        echo 'source /usr/share/bash-completion/bash_completion' >>"$HOME/.bashrc"
    fi
    echo -e "${CYAN}Enabled bash-completion and grc for oh-my-bash.${NC}"
}

install_shell_tools() {
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        install_oh_my_zsh
    elif [[ "$current_shell" == "bash" ]]; then
        install_oh_my_bash
    else
        echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
        exit 1
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_shell_tools
fi