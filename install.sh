#!/bin/bash

# Update package lists and install dependencies
echo "Installing dependencies..."
sudo apt-get install -y nmap traceroute figlet lolcat cowsay toilet nmcli iwlist iwconfig

# Give execute permission to the main script
chmod +x network_scan.sh

# Run the script automatically
echo "Starting NetScan Pro..."
sudo ./network_scan.sh