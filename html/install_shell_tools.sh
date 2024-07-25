#!/usr/bin/env bash

BASE_URL="https://kassel.sh"

# Function to download and source a script
download_and_source_script() {
    local script_name=$1
    local temp_script=$(mktemp)
    curl -s "$BASE_URL/$script_name" -o "$temp_script"
    if [ $? -ne 0 ]; then
        log_error "Failed to download $script_name. Exiting..."
        rm "$temp_script"
        exit 1
    fi
    source "$temp_script"
    if [ $? -ne 0 ]; then
        log_error "Failed to source $script_name. Exiting..."
        rm "$temp_script"
        exit 1
    fi
    rm "$temp_script"
    log_debug "Downloaded and sourced $script_name"
}

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    download_and_source_script "utils.sh"
fi

# Function to install zsh-autosuggestions
install_zsh_autosuggestions() {
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        log_info "zsh-autosuggestions is already installed."
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" >"$temp_file" 2>&1 &
        spinner $! "Installing zsh-autosuggestions"
    fi
}

# Function to install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        log_info "zsh-syntax-highlighting is already installed."
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" >"$temp_file" 2>&1 &
        spinner $! "Installing zsh-syntax-highlighting"
    fi
}

# Function to install Powerlevel10k
install_powerlevel10k() {
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        log_info "Powerlevel10k is already installed."
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" >"$temp_file" 2>&1 &
        spinner $! "Installing Powerlevel10k"
    fi
    if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
        else
            sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
        fi
        log_info "Enabled Powerlevel10k theme for oh-my-zsh."
    else
        log_info "Powerlevel10k theme is already enabled."
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
        log_info "oh-my-zsh is already installed."
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing oh-my-zsh"
    fi

    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
    install_powerlevel10k
    
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        else
            sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        fi
        log_info "Enabled git, zsh-autosuggestions, and zsh-syntax-highlighting plugins for oh-my-zsh."
    else
        log_info "Plugins already configured in .zshrc."
    fi
}

# Function to install bash-completion
install_bash_completion() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! brew list bash-completion &>/dev/null; then
            brew install bash-completion >"$temp_file" 2>&1 &
            spinner $! "Installing bash-completion"
        else
            log_info "bash-completion is already installed."
        fi
    elif ! dpkg -l | grep -qw bash-completion; then
        sudo apt-get install -y bash-completion >"$temp_file" 2>&1 &
        spinner $! "Installing bash-completion"
    else
        log_info "bash-completion is already installed."
    fi
}

# Function to install grc using the automated script
install_grc() {
    if ! command -v grc &>/dev/null; then
        bash -c "$(curl -fsSL https://github.com/garabik/grc/raw/master/grc.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing grc"
    else
        log_info "grc is already installed."
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
        log_info "Configuring Powerbash10k theme for Oh-My-Bash..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's|OSH_THEME=".*"|OSH_THEME="powerbash10k"|' "$HOME/.bashrc"
        else
            sed -i 's|OSH_THEME=".*"|OSH_THEME="powerbash10k"|' "$HOME/.bashrc"
        fi
        log_info "Enabled Powerbash10k theme for Oh-My-Bash."
    else
        log_info "Powerbash10k theme is already enabled."
    fi
}

# Function to install oh-my-bash
install_oh_my_bash() {
    if [ -d "$HOME/.oh-my-bash" ]; then
        log_info "oh-my-bash is already installed."
    else
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" >"$temp_file" 2>&1 &
        spinner $! "Installing oh-my-bash"
    fi

    install_bash_completion
    install_grc
    configure_powerbash10k

    if grep -q "source /usr/share/bash-completion/bash_completion" "$HOME/.bashrc"; then
        if ask "Configuration for bash-completion already exists. Do you want to back it up?"; then
            cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
            log_info "Backup created at $HOME/.bashrc.bak."
        fi
    fi

    if ! grep -q "bash_completion" "$HOME/.bashrc"; then
        echo 'source /usr/share/bash-completion/bash_completion' >>"$HOME/.bashrc"
    fi
    log_info "Enabled bash-completion and grc for oh-my-bash."
}

# Function to install zsh
install_zsh() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! brew list zsh &>/dev/null; then
            brew install zsh >"$temp_file" 2>&1 &
            spinner $! "Installing zsh (brew)"
        else
            log_info "zsh is already installed."
        fi
    elif command -v apt-get &>/dev/null; then
        sudo apt install -y zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (apt)"
    elif command -v yum &>/dev/null; then
        sudo yum install -y zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (yum)"
    elif command -v apk &>/dev/null; then
        sudo apk add zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (apk)"
    elif command -v nix-env &>/dev/null; then
        nix-env -iA nixpkgs.zsh >"$temp_file" 2>&1 &
        spinner $! "Installing zsh (nix)"
    else
        log_error "No supported package manager found. Exiting..."
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
            print_message "Please enter your password to change the default shell to zsh."
            chsh -s $(which zsh)
            current_shell="zsh"
        fi
    fi

    if [[ "$current_shell" == "zsh" ]]; then
        install_oh_my_zsh
    elif [[ "$current_shell" == "bash" ]]; then
        install_oh_my_bash
    else
        log_error "Unsupported shell: $current_shell. Exiting..."
        exit 1
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    temp_file=$(mktemp)
    install_shell_tools
fi