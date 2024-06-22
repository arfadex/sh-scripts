#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Function for displaying a spinner while waiting
spinner() {
    local pid=$1
    local delay=0.25
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        printf "%s" "${spinstr:0:1}"
        spinstr=${spinstr#?}${spinstr%???}
        sleep $delay
        printf "\b"
    done
    printf " \n"
}

# Function to get the next available VM ID
get_next_vm_id() {
    local last_id=$(qm list | awk 'NR>1 {print $1}' | sort -n | awk '$1 < 1000' | tail -n 1)
    echo $((last_id + 1))
}

# Function to get the next available VM name with specific suffix based on template
get_next_name() {
    local base_name=$1
    local template_choice=$2
    local counter=1
    local suffix=""

    case $template_choice in
        1)
            suffix="debian"
            ;;
        2)
            suffix="ubuntu"
            ;;
        3)
            suffix="arch"
            ;;
        4)
            suffix="openbsd"
            ;;
        *)
            echo "Invalid choice."
            exit 1
            ;;
    esac

    local name="${base_name}-${suffix}-${counter}"
    while qm list | grep -q " ${name} "; do
        counter=$((counter + 1))
        name="${base_name}-${suffix}-${counter}"
    done
    echo "$name"
}

# Prompt user to select a template
echo "1) Debian 12"
echo "2) Ubuntu 22.04"
echo "3) Arch Linux"
echo "4) OpenBSD"
read -p "Enter the number corresponding to the template (default 1): " TEMPLATE_CHOICE

# Assign TEMPLATE_ID based on user choice, default to 1 if no choice is made
if [ -z "$TEMPLATE_CHOICE" ]; then
    TEMPLATE_CHOICE=1
fi

case $TEMPLATE_CHOICE in
    1)
        TEMPLATE_ID=1500
        ;;
    2)
        TEMPLATE_ID=2500
        ;;
    3)
        TEMPLATE_ID=3500
        ;;
    4)
        TEMPLATE_ID=4500
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

STORAGE="ZFS1"
BASE_NAME="demo"

# Prompt user for new VM ID
read -p "Enter the new VM ID (or press Enter to auto-generate): " NEW_VM_ID

# Auto-generate VM ID if not provided
if [ -z "$NEW_VM_ID" ]; then
    NEW_VM_ID=$(get_next_vm_id)
fi

# Validate if input is numeric
if ! [[ "$NEW_VM_ID" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a numeric VM ID."
    exit 1
fi

# Prompt user for new VM name
read -p "Enter the new VM name (or press Enter to auto-generate): " NEW_VM_NAME

# If no name provided, find the next available name
if [ -z "$NEW_VM_NAME" ]; then
    NEW_VM_NAME=$(get_next_name "$BASE_NAME" "$TEMPLATE_CHOICE")
fi

# Clone the template
echo -n "Creating clone and starting VM... "
qm clone $TEMPLATE_ID $NEW_VM_ID --name $NEW_VM_NAME --full --storage $STORAGE > /dev/null 2>&1 &

# Capture the PID of qm clone command
QM_PID=$!

# Display spinner while qm clone is running
spinner $QM_PID

# Start the new VM
qm start $NEW_VM_ID > /dev/null 2>&1

# Wait for a few seconds to ensure the VM has booted and obtained an IP address
sleep 20

# Retrieve the IP address from the JSON output of qm guest exec
IP_OUTPUT=$(qm guest exec $NEW_VM_ID ip a)

# Extract and print only the second IP address
IP_ADDRESS=$(echo "$IP_OUTPUT" | grep -Po '(?<=inet\s)\d+(\.\d+){3}(?=/)' | sed -n '2p')

# ANSI escape codes for coloring
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Format the SSH command with rainbow colors
RAINBOW_SSH="${RED}s${YELLOW}s${GREEN}h ${BLUE}m${MAGENTA}e${RED}g${YELLOW}a${GREEN}n${BLUE}e${RESET}@${RED}$IP_ADDRESS${RESET}"

echo ""
echo -e "The IP address of the new VM ($NEW_VM_NAME) is: ${RED}$IP_ADDRESS${RESET}"
echo ""
echo -e "You can SSH to it using this command: ${RAINBOW_SSH}"
