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

    if [ -f "$HOME/.p10k.zsh" ]; then
        ask "p10k.zsh is already installed. Do you want to overwrite it?" || return
    fi

    is_headless
    if [ $? -eq 1 ]; then
        curl -fsSL https://kassel.sh/conf/p10k-headless.zsh -o "$HOME/.p10k.zsh" >"$temp_file" 2>&1 &
    else
        curl -fsSL https://kassel.sh/conf/p10k.zsh -o "$HOME/.p10k.zsh" >"$temp_file" 2>&1 &
    fi
    spinner $! "Downloading p10k.zsh"

    # Add configuration to .zshrc
    echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.' >>"$HOME/.zshrc"
    echo '# Initialization code that may require console input (password prompts, [y/n]' >>"$HOME/.zshrc"
    echo '# confirmations, etc.) must go above this block; everything else may go below.' >>"$HOME/.zshrc"
    echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >>"$HOME/.zshrc"
    echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >>"$HOME/.zshrc"
    echo 'fi' >>"$HOME/.zshrc"
    echo '' >>"$HOME/.zshrc"
    echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >>"$HOME/.zshrc"
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >>"$HOME/.zshrc"
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
        echo 'export GRC_ALIASES=true' >>"$HOME/.bashrc"
        echo "source $HOME/.grc.sh" >>"$HOME/.bashrc"
    fi
}

# Function to configure Powerbash10k for Oh-My-Bash
configure_powerbash10k() {
    if ! grep -q 'OSH_THEME="powerbash10k/powerbash10k"' "$HOME/.bashrc"; then
        echo -e "${CYAN}Configuring Powerbash10k theme for Oh-My-Bash...${NC}"
        sed -i 's|OSH_THEME=".*"|OSH_THEME="powerbash10k"|' "$HOME/.bashrc"
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

# Function to install zsh
install_zsh() {
    echo -e "${CYAN}Installing zsh...${NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt install -y zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (apt)"
    elif command -v yum &>/dev/null; then
        sudo yum install -y zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (yum)"
    elif command -v apk &>/dev/null; then
        sudo apk add zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (apk)"
    elif command -v nix-env &>/dev/null; then
        nix-env -iA nixpkgs.${COMMON_SOFTWARE// / nixpkgs.} >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (nix)"
    elif command -v brew &>/dev/null; then
        brew install zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (brew)"
    else
        echo -e "${RED}No supported package manager found. Exiting...${NC}"
        exit 1
    fi
}

install_shell_tools() {
    current_shell=$(basename "$SHELL")
    log_debug "Current shell: $current_shell"
    # if the current shell is bash ask if the user wants to switch to zsh
    if [[ "$current_shell" == "bash" ]]; then
        if ask "Do you want to switch to zsh?"; then
            # Change the default shell to zsh
            install_zsh
            chsh -s $(which zsh)
            current_shell="zsh"
        fi
    fi

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
    $temp_file=$(mktemp)
    install_shell_tools
fi
