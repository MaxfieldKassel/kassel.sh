#!/usr/bin/env bash
BASE_URL="https://kassel.sh"

# Function to download and source a script
download_and_source_script() {
    local script_name=$1
    local temp_script=$(mktemp)
    curl -s "$BASE_URL/$script_name" -o "$temp_script"
    if [ $? -ne 0 ]; then
        echo "Failed to download $script_name. Exiting..."
        rm "$temp_script"
        exit 1
    fi
    source "$temp_script"
    if [ $? -ne 0 ]; then
        echo "Failed to source $script_name. Exiting..."
        rm "$temp_script"
        exit 1
    fi
    rm "$temp_script"
}

# Add utility functions if not already defined
if ! declare -f spinner &>/dev/null; then
    download_and_source_script "utils.sh"
fi

# Ensure that necessary utilities are installed
check_and_install_utilities() {
    local missing_utils=()
    for util in duti osascript awk grep sed; do
        if ! command -v "$util" &>/dev/null; then
            missing_utils+=("$util")
        fi
    done

    if [ ${#missing_utils[@]} -ne 0 ]; then
        log_error "The following utilities are missing: ${missing_utils[*]}"
        if ask "Do you want to install them?"; then
            log_info "Installing missing utilities..."
            if command -v brew &>/dev/null; then
                for util in "${missing_utils[@]}"; do
                    brew install "$util" &
                    spinner $! "Installing $util (brew)"
                done
            else
                log_error "Homebrew is required to install utilities on macOS. Please install Homebrew first."
                exit 1
            fi
        else
            log_error "Cannot proceed without installing the necessary utilities. Exiting..."
            exit 1
        fi
    fi
}

# Check and install necessary utilities
check_and_install_utilities

# Get the bundle identifiers
xcode_id=$(osascript -e 'id of app "Xcode"')
vscode_id=$(osascript -e 'id of app "Visual Studio Code"')

if [ -z "$xcode_id" ]; then
    log_error "Xcode is not installed."
    exit 1
fi

if [ -z "$vscode_id" ]; then
    log_error "Visual Studio Code is not installed."
    exit 1
fi

# Function to get all known file extensions from lsregister
get_all_extensions() {
    extensions_file=$(mktemp)
    {
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump 2>/dev/null \
            | grep -oE '\.[a-zA-Z0-9]+$' \
            | awk -F. '{print $NF}' \
            | sort -u >"$extensions_file"
    } &

    spinner $! "Gathering file extensions"

    extensions=()
    while IFS= read -r line; do
        extensions+=("$line")
    done < "$extensions_file"
    rm "$extensions_file"
}

# Collect all known file extensions
get_all_extensions

if [ ${#extensions[@]} -eq 0 ]; then
    log_error "No file extensions found."
    exit 1
fi

# Function to find extensions where Xcode is the default application
find_xcode_extensions() {
    xcode_extensions_file=$(mktemp)
    {
        for ext in "${extensions[@]}"; do
            default_app_id=$(duti -x "$ext" 2>/dev/null | grep 'com.apple.dt.Xcode')
            if [ ! -z "$default_app_id" ]; then
                echo "$ext" >>"$xcode_extensions_file"
            fi
        done
    } &

    spinner $! "Checking extensions associated with Xcode"

    xcode_extensions=()
    while IFS= read -r line; do
        xcode_extensions+=("$line")
    done < "$xcode_extensions_file"
    rm "$xcode_extensions_file"
}

# Find extensions where Xcode is the default application
find_xcode_extensions

if [ ${#xcode_extensions[@]} -eq 0 ]; then
    log_info "No file extensions found where Xcode is the default application."
    exit 0
fi

log_info "Found the following extensions associated with Xcode:"
for ext in "${xcode_extensions[@]}"; do
    echo -e "  - .$ext"
done


set_default_app() {
    local ext=$1
    local app_id=$2
    local mode=$3
    duti -s "$app_id" "$ext" "$mode"
    # Check if the change was successful
    return $(duti -x "$ext" | grep -q "$app_id")
}

# Ask the user if they want to change all or go one by one
if ask "Do you want to change the default application to VSCode for ALL these extensions?"; then
    {
        for ext in "${xcode_extensions[@]}"; do
            {
                set_default_app "$ext" "$vscode_id" all
            } &
            spinner $! "Changing .$ext to open with VSCode"
        done
    } 

    log_success "All extensions have been updated."
else
    for ext in "${xcode_extensions[@]}"; do
        if ask "Change default application for .$ext to VSCode?"; then
            {
                set_default_app "$ext" "$vscode_id" all
            } &
            spinner $! "Changing .$ext to open with VSCode"
        else
            log_info "Skipping .$ext"
        fi
    done
    log_success "Selected extensions have been updated."
fi
