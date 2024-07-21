#!/bin/bash

# Add util functions if not already defined
if ! declare -f spinner &>/dev/null; then
    source <(curl -s "https://kassel.sh/utils.sh")
fi


# Function to check if the system is headless
is_headless() {
    if [[ -z "$DISPLAY" ]] && [[ $(tty) == /dev/tty* ]]; then
        return 0
    else
        return 1
    fi
}

# Function to install Nerd Font
install_nerd_font() {
    local font="Inconsolata"
    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf"
    local font_dir="$HOME/.local/share/fonts"

    echo -e "${CYAN}Installing $font Nerd Font...${NC}"

    mkdir -p "$font_dir"
    curl -fLo "$font_dir/InconsolataNerdFont-Regular.ttf" "$font_url" >"$temp_file" 2>&1 &
    spinner $! "Downloading $font Nerd Font"

    # Refresh font cache
    fc-cache -fv >"$temp_file" 2>&1 &
    spinner $! "Refreshing font cache"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully installed $font Nerd Font${NC}"
    else
        echo -e "${RED}Failed to install $font Nerd Font${NC}"
    fi
}

# Function to set Nerd Font for the console
set_nerd_font_console() {
    local font_path="/usr/share/consolefonts/Lat15-TerminusBold14.psf.gz"
    echo -e "${CYAN}Setting $font_path for the console...${NC}"

    sudo echo "FONT=$font_path" > /etc/default/console-setup
    sudo echo "FONTFACE=\"Terminus\"" >> /etc/default/console-setup
    sudo echo "FONTSIZE=\"14\"" >> /etc/default/console-setup

    sudo update-initramfs -u

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Set $font_path for the console${NC}"
    else
        echo -e "${RED}Failed to set $font_path for the console${NC}"
    fi
}

# Function to set Nerd Font for the terminal
set_nerd_font_terminal() {
    local font_name="Inconsolata Nerd Font"
    echo -e "${CYAN}Setting $font_name for the terminal...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        defaults write com.apple.Terminal "Default Window Settings" -string "$font_name"
        defaults write com.apple.Terminal "Startup Window Settings" -string "$font_name"
        echo -e "${GREEN}Set $font_name for macOS Terminal${NC}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        gsettings set org.gnome.desktop.interface monospace-font-name "$font_name 11"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Set $font_name for GNOME Terminal${NC}"
        else
            echo -e "${RED}Failed to set $font_name for GNOME Terminal${NC}"
        fi
    fi
}

# Function to install and set Nerd Font
install_and_set_nerd_font() {
    install_nerd_font

    if is_headless; then
        set_nerd_font_console
    else
        set_nerd_font_terminal
    fi
}