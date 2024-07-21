#!/bin/bash

BASE_URL="https://kassel.sh"

download_and_source_script() {
  local script_name=$1
  local temp_file=$(mktemp)
  curl -sSL "$BASE_URL/$script_name" -o "$temp_file"
  source "$temp_file"
  rm -f "$temp_file"
}

# Download and source the scripts
download_and_source_script "spinner.sh"
download_and_source_script "utils.sh"
download_and_source_script "install_common_software.sh"
download_and_source_script "install_developer_tools.sh"
download_and_source_script "install_nerd_fonts.sh"
download_and_source_script "install_shell_tools.sh"
download_and_source_script "update_and_upgrade.sh"

# Main script
AUTO=false
while getopts ":a" opt; do
  case $opt in
  a)
    AUTO=true
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Create a temporary file for command output
temp_file=$(mktemp)

# Request sudo permissions
request_sudo

# Check and install necessary utilities
check_and_install_utilities

# Update package lists
update_package_lists

# Ask for upgrade
if ask "Do you want to upgrade all packages?"; then
  upgrade_packages
fi

# Install developer tools and Homebrew on macOS if needed
if [[ "$OSTYPE" == "darwin"* ]]; then
  install_macos_tools
fi

# Detect current shell
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
  install_oh_my_zsh
elif [[ "$current_shell" == "bash" ]]; then
  install_oh_my_bash
else
  echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
  rm "$temp_file"
  exit 1
fi

# Install common software
install_software

# Install Nerd Fonts and set for terminal
install_nerd_fonts
set_nerd_fonts_terminal

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Setup complete!${NC}"
  rm "$temp_file"
else
  echo -e "${RED}An error occurred. Check the log file for details: $temp_file${NC}"
fi
