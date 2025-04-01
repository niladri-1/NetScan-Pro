#!/bin/bash

# Check if required commands are installed: nmap
REQUIRED_COMMANDS=("nmap")
OPTIONAL_COMMANDS=("figlet" "lolcat" "toilet" "nmcli" "iwlist" "iwconfig")

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

# Create results directory if it doesn't exist
RESULTS_DIR="results"
mkdir -p "$RESULTS_DIR"

LOG_FILE="$RESULTS_DIR/network_scan_$(date +'%Y%m%d_%H%M%S').log"

# Function to log output with timestamps
log() {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

display_banner() {
    if command -v figlet &> /dev/null; then
        terminal_width=$(tput cols)
        banner=$(figlet "NetScan Pro")
        while IFS= read -r line; do
            padding=$(( (terminal_width - ${#line}) / 2 ))
            printf "%*s%s\n" "$padding" "" "$line"
        done <<< "$banner" | { command -v lolcat &> /dev/null && lolcat || cat; }
    else
        echo -e "${GREEN}========== NetScan Pro ========== ${NC}"
    fi
}

get_host_ip() {
    hostname -I | awk '{print $1}'
}

get_default_gateway() {
    ip route | awk '/^default/ {print $3}'
}

calculate_network() {
    local host_ip=$1
    ip -o -f inet addr show | awk -v ip="$host_ip" '$0 ~ ip {print $4}'
}

scan_network() {
    local network=$1
    log "${BLUE}[*] Scanning network $network for live hosts...${NC}"
    nmap -sn "$network" | tee -a "$LOG_FILE"
}

port_scan() {
    local target=$1
    log "${BLUE}[*] Performing port scan on $target...${NC}"
    sudo nmap -sS -sV -O "$target" | tee -a "$LOG_FILE"
}

vulnerability_scan() {
    local target=$1
    log "${BLUE}[*] Scanning $target for vulnerabilities...${NC}"
    sudo nmap -sV --script=vuln "$target" | tee -a "$LOG_FILE"
}

find_web_servers() {
    log "${BLUE}[*] Scanning for web servers on the network...${NC}"
    nmap --open -p 80,443 "$network" | tee -a "$LOG_FILE"
}

find_wireless_connections() {
    log "${BLUE}[*] Scanning for available wireless connections...${NC}"
    if command -v nmcli &> /dev/null; then
        log "Using nmcli for wireless scan."
        sudo nmcli dev wifi list | tee -a "$LOG_FILE"
    elif command -v iwlist &> /dev/null; then
        interface=$(iwconfig 2>/dev/null | grep 'ESSID' | awk '{print $1}')
        if [ -n "$interface" ]; then
            log "Using iwlist on interface $interface"
            sudo iwlist "$interface" scan | grep -E 'ESSID|Signal' | tee -a "$LOG_FILE"
        else
            log "${RED}[!] No wireless interface found. Ensure WiFi is enabled.${NC}"
        fi
    else
        log "${RED}[!] No suitable tool found to scan for wireless networks.${NC}"
    fi
}

clear_screen() {
    clear
}

show_menu() {
    echo -e "\n${YELLOW}Select an option:${NC}"
    echo -e "1. Scan for live hosts on the network"
    echo -e "2. Perform a port scan on a specific host"
    echo -e "3. Find vulnerabilities on a specific host"
    echo -e "4. Find web servers on the network"
    echo -e "5. Find available wireless connections"
    echo -e "6. Clear the screen"
    echo -e "7. Exit"
    echo -en "${GREEN}Enter your choice [1-7]: ${NC}"
}

clear_screen
display_banner

host_ip=$(get_host_ip)
gateway=$(get_default_gateway)
network=$(calculate_network "$host_ip")

log "${GREEN}Host IP: ${NC}$host_ip"
log "${GREEN}Default Gateway: ${NC}$gateway"
log "${GREEN}Network: ${NC}$network"
log "${GREEN}Scan results will be stored in: ${NC}$RESULTS_DIR"

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
            find_web_servers
            ;;
        5)
            find_wireless_connections
            ;;
        6)
            clear_screen
            ;;
        7)
            log "${YELLOW}Exiting. Have a great day!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select between 1 and 7.${NC}"
            ;;
    esac
done