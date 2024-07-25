#!/usr/bin/env bash

BASE_URL="https://kassel.sh"

# The reason for this function is that some operating systems
# do not support sourcing a script directly from a URL. This
# function downloads the script to a temporary file, sources it,
download_and_source_script() {
    local script_name=$1
    local temp_script=$(mktemp)
    curl -s "$BASE_URL/$script_name" -o "$temp_script"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to download $script_name. Exiting...${NC}"
        rm "$temp_script"
        exit 1
    fi
    source "$temp_script"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to source $script_name. Exiting...${NC}"
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

# Function to install and set the terminal font
install_and_set_terminal_font() {
    local font="Hack Nerd Font"
    local font_dir="$HOME/.local/share/fonts"
    local font_file="$font_dir/Hack Regular Nerd Font Complete.ttf"

    if [[ -f "$font_file" ]]; then
        echo -e "${CYAN}$font is already installed. Skipping...${NC}"
        return 0
    fi

    echo -e "${CYAN}Installing $font...${NC}"

    mkdir -p "$font_dir"
    local font_urls=(
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip"
    )

    for font_url in "${font_urls[@]}"; do
        local temp_zip=$(mktemp)
        curl -fLo "$temp_zip" "$font_url" >"$temp_file" 2>&1 &
        spinner $! "Downloading $font"

        unzip -o "$temp_zip" -d "$font_dir" >"$temp_file" 2>&1 &
        spinner $! "Extracting $font"
        rm "$temp_zip"

        # Remove all windows compatible fonts
        find "$font_dir" -type f -name "*Windows Compatible*" -delete >"$temp_file" 2>&1 &
        spinner $! "Removing Windows compatible fonts"
    done

    # Refresh font cache
    fc-cache -fv >"$temp_file" 2>&1 &
    spinner $! "Refreshing font cache"

    local font_name="Hack Nerd Font"
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

# This function uses the Cozette font for the console,
# which is a patched version of the Cozette font, which
# has symbols for powerline and other icons. The font
# is downloaded from the official GitHub release page.
install_and_set_console_font() {
    local font_url="https://github.com/slavfox/Cozette/releases/download/v.1.24.1/cozette_hidpi.psf"
    local font_path="/usr/share/consolefonts/cozette_hidpi.psf"
    local temp_file=$(mktemp)

    if [[ -f "$font_path" ]]; then
        echo -e "${CYAN}Cozette font is already installed. Skipping...${NC}"
        return 0
    fi

    echo -e "${CYAN}Installing Cozette font for the console...${NC}"

    sudo mkdir -p /usr/share/consolefonts
    sudo curl -fLo "$font_path" "$font_url" >"$temp_file" 2>&1 &
    spinner $! "Downloading Cozette console font"

    echo -e "${CYAN}Setting Cozette font for the console...${NC}"

    sudo bash -c "echo 'FONT=$font_path' > /etc/default/console-setup"
    sudo bash -c "echo 'FONTFACE=\"Cozette\"' >> /etc/default/console-setup"
    sudo bash -c "echo 'FONTSIZE=\"16\"' >> /etc/default/console-setup"

    sudo update-initramfs -u >"$temp_file" 2>&1 &
    spinner $! "Updating initramfs"
}

# Function to install and set font
install_and_set_font() {
    is_headless
    if [[ $? -eq 1 ]]; then
        log_debug "Headless system detected. Installing and setting Cozette font for the console..."
        install_and_set_console_font
    else
        log_debug "Setting font for the terminal..."
        install_and_set_terminal_font
    fi
}

# Check if script is being executed or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    DEBUG=false
    # create a temporary file
    temp_file=$(mktemp)

    install_and_set_font
fi