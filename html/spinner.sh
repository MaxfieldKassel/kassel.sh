#!/bin/bash

# Colors for output
NC="\033[0m" # No Color
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

# Function to show a loading spinner with custom text
spinner() {
    local pid=$1
    local text=$2
    local delay=0.1
    local spinstr='/-\|'
    echo -ne "${YELLOW}${text}... ${NC}"
    while ps -p $pid >/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    wait $pid
    local status=$?
    printf "    \b\b\b\b"
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}Done!${NC}"
    else
        echo -e "${RED}Fail!${NC}"
    fi
}
