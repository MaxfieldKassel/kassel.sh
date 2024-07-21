#!/bin/bash

# Function to install Nerd Fonts
install_nerd_fonts() {
    echo -e "${YELLOW}Installing Nerd Fonts...${NC}"
    git clone --depth 1 -b master https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts >"$temp_file" 2>&1 &
    spinner $! "Cloning Nerd Fonts"
    /tmp/nerd-fonts/install.sh Inconsolata >"$temp_file" 2>&1 &
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

install_nerd_fonts
set_nerd_fonts_terminal
