#!/usr/bin/env bash

BASE_URL="https://kassel.sh"

DEBUG=true

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
    log_error "Invalid option: -$OPTARG"
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
log_debug "Temporary file: $temp_file"

log_debug "Requesting sudo permissions"
request_sudo

log_debug "Installing developer tools and Homebrew on macOS if needed"
if [[ "$OSTYPE" == "darwin"* ]]; then
  install_macos_tools
fi

log_debug "Checking and installing necessary utilities"
check_and_install_utilities

log_debug "Updating package lists"
update_and_upgrade

log_debug "Installing common software"
install_software

log_debug "Installing shell tools"
install_shell_tools

log_debug "Installing font"
install_and_set_font

# Check if the previous commands were successful
if [ $? -eq 0 ]; then
  log_success "Setup complete!"
  # Don't remove the temp file if debug is enabled
  [ "$DEBUG" = true ] || rm "$temp_file"
else
  log_error "An error occurred. Check the log_debug file for details: $temp_file"
fi
