#!/bin/bash
# provision_basic.sh
# Basic provisioning script for a new Debian-based VM

# Exit immediately if a command fails
set -e

export DEBIAN_FRONTEND=noninteractive
# Update package lists and upgrade existing packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl sqlite3 apache2-utils

# Install basic utilities
echo "Installing essential packages..."
sudo apt-get install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    unzip \
    build-essential

# Create a projects directory for the user
echo "Creating projects directory..."
mkdir -p /home/$USER/projects
chown $USER:$USER /home/$USER/projects

# Add a simple welcome message
echo "Welcome to your new VM!" | tee /home/$USER/welcome.txt

# Optional: enable UFW and allow SSH
echo "Configuring UFW firewall..."
sudo apt-get install -y ufw
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "Provisioning complete!"
