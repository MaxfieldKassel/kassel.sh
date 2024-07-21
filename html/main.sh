#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/spinner.sh"

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

# Check and install necessary utilities
source "$(dirname "$0")/utils.sh"
check_and_install_utilities

# Update package lists and upgrade if confirmed
source "$(dirname "$0")/update_and_upgrade.sh"

# Install developer tools and Homebrew on macOS if needed
source "$(dirname "$0")/install_developer_tools.sh"

# Install shell tools (oh-my-zsh or oh-my-bash)
source "$(dirname "$0")/install_shell_tools.sh"

# Install common software
source "$(dirname "$0")/install_common_software.sh"

# Install Nerd Fonts and set for terminal
source "$(dirname "$0")/install_nerd_fonts.sh"

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Setup complete!${NC}"
  rm "$temp_file"
else
  echo -e "${RED}An error occurred. Check the log file for details: $temp_file${NC}"
fi
