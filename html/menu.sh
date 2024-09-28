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


# Function to display the menu and handle user input
display_menu() {
    local subTitle="$1"
    local options=("${@:2}")
    local choice

    # Display subtitle
    echo -e "${BLUE}${subTitle}${RESET}"

    # Display options with numbers
    for i in "${!options[@]}"; do
        echo -e "${GREEN}$((i + 1))${RESET}) ${BLUE}${options[$i]}${RESET}"
    done
    echo

    # Loop until a valid option is selected
    while true; do
        read -s -n1 choice # Read a single character (number) without Enter key

        # Check if the input is a valid number
        if [[ "$choice" =~ ^[0-9]$ ]]; then
            if [[ "$choice" -ge 1 && "$choice" -le "${#options[@]}" ]]; then
                return $((choice - 1)) # Return the selected option index
            fi
        fi
    done
}

# Function to install automatically
auto_install() {
    download_and_source_script "main.sh"
}

# Function to install manually
manual_install() {
    echo "Installing manually..."
}

# Function to open the utilities menu
open_utilities_menu() {
     # Define the utilities menu options
     options=("Proxmox Expand Storage" "Change File Extensions" "Exit")

     title="Utilities"

     if command -v lolcat &>/dev/null; then
         echo -e "$title" | lolcat
     else
         echo -e "${RED}${title}${RESET}"
     fi

     display_menu "Select a utility by pressing the number key:" "${options[@]}"

     case $selected_option in
        1)
            download_and_source_script "proxmox_expand_storage.sh"
            ;;
    2)
        download_and_source_script "change_file_extensions.sh"
        ;;
3)
        echo "Exiting..."
        exit 0
        ;;
        esac
}


# Example usage of the menu
main() {
    # Define your menu options
    options=("Install Automatically" "Install Manually" "Utilities" "Exit")

    # Define the ASCII art title
    title="
 _                      _       _     
| | ____ _ ___ ___  ___| |  ___| |__  
| |/ / _\` / __/ __|/ _ \\ | / __| '_ \\ 
|   < (_| \\__ \__ \\  __/ |_\\__ \\ | | |
|_|\\_\\__,_|___/___/\\___|_(_)___/_| |_|"

    # Display title with lolcat if available
    if command -v lolcat &>/dev/null; then
        echo -e "$title" | lolcat
    else
        echo -e "${RED}${title}${RESET}"
    fi
    echo

    # Call the menu function with the options
    display_menu "Select an option by pressing the number key:" "${options[@]}"
    selected_option=$?

    echo "You selected option $((selected_option + 1)): ${options[$selected_option]}"

    # Handle the selected option
    case $selected_option in
    0)
        auto_install
        ;;
    1)
        manual_install
        ;;
    2)
        open_utilities_menu
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    esac
}

# Run the main function
main
