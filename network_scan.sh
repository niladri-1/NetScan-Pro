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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
        echo -e "${CYAN}=========================================${NC}"
        echo -e "${GREEN}           NetScan Pro v2.0            ${NC}"
        echo -e "${CYAN}=========================================${NC}"
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
    local scan_type=$2

    case $scan_type in
        "quick")
            log "${BLUE}[*] Performing quick port scan on $target...${NC}"
            nmap -T4 --top-ports 100 "$target" | tee -a "$LOG_FILE"
            ;;
        "full")
            log "${BLUE}[*] Performing full port scan on $target...${NC}"
            sudo nmap -sS -sV -O -p- "$target" | tee -a "$LOG_FILE"
            ;;
        *)
            log "${BLUE}[*] Performing standard port scan on $target...${NC}"
            sudo nmap -sS -sV -O "$target" | tee -a "$LOG_FILE"
            ;;
    esac
}

vulnerability_scan() {
    local target=$1
    log "${BLUE}[*] Scanning $target for vulnerabilities...${NC}"
    sudo nmap -sV --script=vuln "$target" | tee -a "$LOG_FILE"
}

find_web_servers() {
    local network=$1
    log "${BLUE}[*] Scanning for web servers on the network...${NC}"
    nmap --open -p 80,443,8080,8443 "$network" | tee -a "$LOG_FILE"
}

find_databases() {
    local network=$1
    log "${BLUE}[*] Scanning for database servers on the network...${NC}"
    nmap --open -p 1433,3306,5432,27017,6379,9200 "$network" | tee -a "$LOG_FILE"
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
            sudo iwlist "$interface" scan | grep -E 'ESSID|Signal|Quality|Channel' | tee -a "$LOG_FILE"
        else
            log "${RED}[!] No wireless interface found. Ensure WiFi is enabled.${NC}"
        fi
    else
        log "${RED}[!] No suitable tool found to scan for wireless networks.${NC}"
    fi
}

network_device_discovery() {
    local network=$1
    log "${BLUE}[*] Performing network device discovery on $network...${NC}"
    sudo nmap -sn -PR -PE -PA21,22,23,80,443,3389 "$network" | tee -a "$LOG_FILE"
}

generate_report() {
    local report_file="$RESULTS_DIR/network_report_$(date +'%Y%m%d_%H%M%S').html"
    log "${BLUE}[*] Generating HTML report from scan data...${NC}"

    echo "<!DOCTYPE html>
<html>
<head>
    <title>Network Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #3498db; }
        .section { margin-bottom: 20px; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        pre { background-color: #f8f8f8; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>Network Scan Report</h1>
    <div class='section'>
        <h2>Scan Information</h2>
        <p>Date: $(date +'%Y-%m-%d %H:%M:%S')</p>
        <p>Host IP: $host_ip</p>
        <p>Network: $network</p>
        <p>Default Gateway: $gateway</p>
    </div>
    <div class='section'>
        <h2>Scan Results</h2>
        <pre>$(cat "$LOG_FILE")</pre>
    </div>
</body>
</html>" > "$report_file"

    log "${GREEN}[+] Report generated: $report_file${NC}"
}

clear_screen() {
    clear
    display_banner

    host_ip=$(get_host_ip)
    gateway=$(get_default_gateway)
    network=$(calculate_network "$host_ip")

    log "${GREEN}Host IP: ${NC}$host_ip"
    log "${GREEN}Default Gateway: ${NC}$gateway"
    log "${GREEN}Network: ${NC}$network"
    log "${GREEN}Scan results will be stored in: ${NC}$RESULTS_DIR"
}


show_menu() {
    echo -e "\n${YELLOW}Select an option:${NC}"
    echo -e "${CYAN}=== Network Discovery ===${NC}"
    echo -e "1. Scan for live hosts on the network"
    echo -e "2. Perform a detailed network device discovery"

    echo -e "\n${CYAN}=== Port Scanning ===${NC}"
    echo -e "3. Perform a quick port scan on a specific host"
    echo -e "4. Perform a standard port scan on a specific host"
    echo -e "5. Perform a full port scan on a specific host"

    echo -e "\n${CYAN}=== Service Discovery ===${NC}"
    echo -e "6. Find web servers on the network"
    echo -e "7. Find database servers on the network"
    echo -e "8. Find vulnerabilities on a specific host"

    echo -e "\n${CYAN}=== Wireless ===${NC}"
    echo -e "9. Find available wireless connections"

    echo -e "\n${CYAN}=== Utilities ===${NC}"
    echo -e "10. Generate HTML report from scan data"
    echo -e "11. Clear the screen"
    echo -e "12. Exit"

    echo -en "${GREEN}Enter your choice [1-12]: ${NC}"
}

# Main script execution
clear_screen


while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            scan_network "$network"
            ;;
        2)
            network_device_discovery "$network"
            ;;
        3)
            echo -en "${GREEN}Enter target host IP for quick port scan: ${NC}"
            read -r target
            port_scan "$target" "quick"
            ;;
        4)
            echo -en "${GREEN}Enter target host IP for standard port scan: ${NC}"
            read -r target
            port_scan "$target" "standard"
            ;;
        5)
            echo -en "${GREEN}Enter target host IP for full port scan: ${NC}"
            read -r target
            port_scan "$target" "full"
            ;;
        6)
            find_web_servers "$network"
            ;;
        7)
            find_databases "$network"
            ;;
        8)
            echo -en "${GREEN}Enter target host IP for vulnerability scan: ${NC}"
            read -r target
            vulnerability_scan "$target"
            ;;
        9)
            find_wireless_connections
            ;;
        10)
            generate_report
            ;;
        11)
            clear_screen
            ;;
        12)
            log "${YELLOW}Exiting. Have a great day!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select between 1 and 12.${NC}"
            ;;
    esac
done