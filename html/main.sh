#!/usr/bin/env bash

BASE_URL="https://kassel.sh"

DEBUG=false

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
download_and_source_script "install_font.sh"
download_and_source_script "install_shell_tools.sh"
download_and_source_script "update_and_upgrade.sh"

# Main script
AUTO=false
temp_file=$(mktemp)

log_debug "Requesting sudo permissions"
request_sudo

log_debug "Installing developer tools and Homebrew on macOS if needed"
if [[ "$OSTYPE" == "darwin"* ]]; then
  install_macos_tools
fi

log_debug "Checking and installing necessary utilities"
check_and_install_utilities

log_debug "Updating package lists"
update_package_lists

log_debug "Asking for upgrade confirmation"
if ask "Do you want to upgrade all packages?"; then
  log_debug "Upgrading packages"
  upgrade_packages
fi

log_debug "Installing common software"
install_software

log_debug "Detecting current shell"
current_shell=$(basename "$SHELL")

if [[ "$current_shell" == "zsh" ]]; then
  log_debug "Installing oh-my-zsh"
  install_oh_my_zsh
elif [[ "$current_shell" == "bash" ]]; then
  log_debug "Installing oh-my-bash"
  install_oh_my_bash
else
  echo -e "${RED}Unsupported shell: $current_shell. Exiting...${NC}"
  rm "$temp_file"
  exit 1
fi

log_debug "Installing font"
install_and_set_font

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Setup complete!${NC}"
  rm "$temp_file"
else
  echo -e "${RED}An error occurred. Check the log_debug file for details: $temp_file${NC}"
fi
