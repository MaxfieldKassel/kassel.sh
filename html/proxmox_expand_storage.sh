#!/bin/bash

# Check if the script is run as root (with sudo)
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Check if growpart is installed
if ! command -v growpart &> /dev/null; then
  echo "growpart could not be found. Installing..."
  sudo apt-get update && sudo apt-get install -y cloud-guest-utils
fi

# Check if resize2fs is installed
if ! command -v resize2fs &> /dev/null; then
  echo "resize2fs could not be found. Installing..."
  sudo apt-get update && sudo apt-get install -y e2fsprogs
fi

# Prompt user for the disk and partition to resize
echo "Enter the disk (e.g., /dev/sda):"
read DISK
echo "Enter the partition number to resize (e.g., 2 for /dev/sda2):"
read PART

PARTITION="${DISK}${PART}"

# Print the current size of the partition
echo "Current partition size:"
sudo lsblk -o NAME,SIZE,MOUNTPOINT | grep "$(basename $PARTITION)"

# Prompt for confirmation
echo "Do you want to resize the partition /dev/${PARTITION}? This action cannot be undone. (yes/no)"
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Operation cancelled."
  exit 0
fi

# Run growpart and resize2fs
echo "Resizing partition /dev/${PARTITION}..."
sudo growpart $DISK $PART

# Resize the filesystem
echo "Resizing the filesystem on /dev/${PARTITION}..."
sudo resize2fs ${PARTITION}

# Print the new size of the partition
echo "New partition size:"
sudo lsblk -o NAME,SIZE,MOUNTPOINT | grep "$(basename $PARTITION)"

# Success message
echo "Partition /dev/${PARTITION} has been successfully resized!"
