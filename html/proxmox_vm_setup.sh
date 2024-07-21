#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install qemu-guest-agent for Proxmox integration
echo "Installing qemu-guest-agent..."
sudo apt install -y qemu-guest-agent

# Enable and start qemu-guest-agent service
echo "Enabling and starting qemu-guest-agent service..."
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Modify /etc/default/grub for serial console
echo "Configuring GRUB for serial console..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0"/' /etc/default/grub
sudo sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL="console serial"/' /etc/default/grub
sudo sed -i 's/^#GRUB_SERIAL_COMMAND=.*/GRUB_SERIAL_COMMAND="serial --speed=115200"/' /etc/default/grub

# Update GRUB
echo "Updating GRUB configuration..."
sudo update-grub

# Prompt the user to reboot the VM
echo "Setup complete! Ensure that the display is set to 'Serial terminal 0' in the Proxmox Hardware tab."
read -p "Would you like to reboot the VM now to apply the changes? (y/n): " REBOOT

if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    echo "Rebooting the VM..."
    sudo reboot
else
    echo "Please remember to reboot the VM later to apply the changes."
fi
