#!/bin/bash

BASE_URL="https://kassel.sh"

DEBUG=false

download_and_source_script() {
    local script_name=$1
    source <(curl -s "$BASE_URL/$script_name")
    log "Downloaded $script_name"
}

# Parse options
while getopts ":ad" opt; do
  case $opt in
    a)
      AUTO=true
      ;;
    d)
      DEBUG=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Download and source the scripts
download_and_source_script "utils.sh"
download_and_source_script "install_common_software.sh"
download_and_source_script "install_developer_tools.sh"
download_and_source_script "install_nerd_fonts.sh"
download_and_source_script "install_shell_tools.sh"
download_and_source_script "update_and_upgrade.sh"

# Main script
AUTO=false
temp_file=$(mktemp)

log "Requesting sudo permissions"
request_sudo

log "Checking and installing necessary utilities"
check_and_install_utilities

log "Updating package lists"
update_package_lists

log "Asking for upgrade confirmation"
if ask "Do you want to upgrade all packages?"; then
    log "Upgrading packages"
    upgrade_packages
fi

log "Installing developer tools and Homebrew on macOS if needed"
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos_tools
fi

log "Detecting current shell"
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
    log "Installing oh-my-zsh"
    install_oh_my_zsh
elif [[ "$current_shell" == "bash" ]]; then
    log "Installing oh-my-bash"
    install_oh_my_bash
else
    echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
    rm "$temp_file"
    exit 1
fi

log "Installing common software"
install_software

log "Installing font"
install_and_set_font

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Setup complete!${NC}"
    rm "$temp_file"
else
    echo -e "${RED}An error occurred. Check the log file for details: $temp_file${NC}"
fi