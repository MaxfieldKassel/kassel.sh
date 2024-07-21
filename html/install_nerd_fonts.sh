#!/bin/bash


# Function to install Nerd Fonts
install_nerd_fonts() {
    local font="Inconsolata"
    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/Regular/InconsolataNerdFont-Regular.ttf"
    local font_dir="$HOME/.local/share/fonts"

    echo -e "${YELLOW}Installing $font Nerd Font...${NC}"

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

# Function to set Nerd Fonts for the terminal
set_nerd_fonts_terminal() {
    local font_name="Inconsolata Nerd Font"
    echo -e "${YELLOW}Setting $font_name for the terminal...${NC}"
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