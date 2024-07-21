#!/bin/bash

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    source <(curl -s "https://kassel.sh/utils.sh")
fi

# Function to install and set the terminal font
install_and_set_terminal_font() {
    local font="Inconsolata"
    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf"
    local font_dir="$HOME/.local/share/fonts"

    echo -e "${CYAN}Installing $font font...${NC}"

    mkdir -p "$font_dir"
    curl -fLo "$font_dir/InconsolataNerdFont-Regular.ttf" "$font_url" >"$temp_file" 2>&1 &
    spinner $! "Downloading $font font"

    # Refresh font cache
    fc-cache -fv >"$temp_file" 2>&1 &
    spinner $! "Refreshing font cache"

    local font_name="Inconsolata Nerd Font"
    echo -e "${CYAN}Setting $font_name for the terminal...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        defaults write com.apple.Terminal "Default Window Settings" -string "$font_name"
        defaults write com.apple.Terminal "Startup Window Settings" -string "$font_name" >"$temp_file" 2>&1 &
        spinner $! "Setting $font_name for Terminal"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        gsettings set org.gnome.desktop.interface monospace-font-name "$font_name 11" >"$temp_file" 2>&1 &
        spinner $! "Setting $font_name for GNOME Terminal"
    fi
}

# Function to install and set the console font
install_and_set_console_font() {
    local font_url="https://github.com/xeechou/Inconsolata-psf/raw/master/Inconsolata-16r.psf"
    local font_path="/usr/share/consolefonts/Inconsolata-16r.psf"

    echo -e "${CYAN}Installing Inconsolata font for the console...${NC}"

    sudo mkdir -p /usr/share/consolefonts
    sudo curl -fLo "$font_path" "$font_url" >"$temp_file" 2>&1 &
    spinner $! "Downloading Inconsolata console font"

    echo -e "${CYAN}Setting Inconsolata font for the console...${NC}"

    sudo bash -c "echo 'FONT=$font_path' > /etc/default/console-setup"
    sudo bash -c "echo 'FONTFACE=\"Inconsolata\"' >> /etc/default/console-setup"
    sudo bash -c "echo 'FONTSIZE=\"16\"' >> /etc/default/console-setup"

    sudo update-initramfs -u >"$temp_file" 2>&1 &
    spinner $! "Updating initramfs"
}

# Function to install and set font
install_and_set_font() {
    if [[ -z "$DISPLAY" ]] && ! command -v gnome-terminal &>/dev/null && ! command -v dconf &>/dev/null; then
        HEADLESS=1
    else
        HEADLESS=0
    fi

    if [[ $HEADLESS -eq 1 ]]; then
        log "Headless system detected. Installing and setting Inconsolata font for the console..."
        install_and_set_console_font
    else
        log "Setting font for the terminal..."
        install_and_set_terminal_font
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_and_set_font
fi
