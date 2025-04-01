#!/bin/bash

# Check if required commands are installed: nmap
REQUIRED_COMMANDS=("nmap")
OPTIONAL_COMMANDS=("figlet" "lolcat" "cowsay")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install $cmd to run this script."
        exit 1
    fi
done

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOG_FILE="network_scan_$(date +'%Y%m%d_%H%M%S').log"

# Function to log output with timestamps
log() {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Display a banner using figlet (with optional lolcat)
display_banner() {
    if command -v figlet &> /dev/null; then
        banner=$(figlet "NetScan Pro")
        if command -v lolcat &> /dev/null; then
            echo "$banner" | lolcat
        else
            echo -e "${GREEN}$banner${NC}"
        fi
    else
        echo -e "${GREEN}========== NetScan Pro ==========${NC}"
    fi
}

# Fun message using cowsay if available
fun_message() {
    if command -v cowsay &> /dev/null; then
        if command -v lolcat &> /dev/null; then
            cowsay "Happy Scanning!" | lolcat
        else
            cowsay "Happy Scanning!"
        fi
    else
        echo -e "${GREEN}Happy Scanning!${NC}"
    fi
}

# Get host IP (first available address)
get_host_ip() {
    hostname -I | awk '{print $1}'
}

# Get default gateway from the routing table
get_default_gateway() {
    ip route | awk '/^default/ {print $3}'
}

# Determine network in CIDR notation using the IP command
calculate_network() {
    local host_ip=$1
    ip -o -f inet addr show | awk -v ip="$host_ip" '$0 ~ ip {print $4}'
}

# Scan the network for live hosts using nmap
scan_network() {
    local network=$1
    log "${BLUE}[*] Scanning network $network for live hosts...${NC}"
    nmap -sn "$network" | tee -a "$LOG_FILE"
}

# Perform a port scan (SYN scan with service detection and OS detection) on a given host
port_scan() {
    local target=$1
    log "${BLUE}[*] Performing port scan on $target...${NC}"
    sudo nmap -sS -sV -O "$target" | tee -a "$LOG_FILE"
}

# Perform a vulnerability scan on a given host using Nmap scripts
vulnerability_scan() {
    local target=$1
    log "${BLUE}[*] Scanning $target for vulnerabilities...${NC}"
    sudo nmap -sV --script=vuln "$target" | tee -a "$LOG_FILE"
}

# Clear the terminal screen
clear_screen() {
    clear
}

# Display an interactive menu for user options
show_menu() {
    echo -e "\n${YELLOW}Select an option:${NC}"
    echo -e "1. Scan for live hosts on the network"
    echo -e "2. Perform a port scan on a specific host"
    echo -e "3. Find vulnerabilities on a specific host"
    echo -e "4. Clear the screen"
    echo -e "5. Exit"
    echo -en "${GREEN}Enter your choice [1-5]: ${NC}"
}

# Main execution
clear_screen
display_banner
fun_message

host_ip=$(get_host_ip)
gateway=$(get_default_gateway)
network=$(calculate_network "$host_ip")

log "${GREEN}Host IP: ${NC}$host_ip"
log "${GREEN}Default Gateway: ${NC}$gateway"
log "${GREEN}Network: ${NC}$network"
log "${GREEN}Scan results will be logged to: ${NC}$LOG_FILE"

# Main interactive loop
while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            scan_network "$network"
            ;;
        2)
            echo -en "${GREEN}Enter target host IP for port scan: ${NC}"
            read -r target
            port_scan "$target"
            ;;
        3)
            echo -en "${GREEN}Enter target host IP for vulnerability scan: ${NC}"
            read -r target
            vulnerability_scan "$target"
            ;;
        4)
            clear_screen
            ;;
        5)
            log "${YELLOW}Exiting. Have a great day!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select between 1 and 5.${NC}"
            ;;
    esac
done
