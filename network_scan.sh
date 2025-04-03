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

WEB_RESULT="Web Pages"
mkdir -p "$WEB_RESULT"

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
    local report_file="$WEB_RESULT/network_report_$(date +'%Y%m%d_%H%M%S').html"
    log "${BLUE}[*] Generating HTML report from scan data...${NC}"

    # Parse the log file to extract different sections
    local live_hosts=$(grep -A 20 "Scanning network .* for live hosts" "$LOG_FILE" | grep -E "Nmap scan report|Host is up" | sed 's/Nmap scan report for //')
    local port_scans=$(grep -A 50 "Performing .* port scan on" "$LOG_FILE" | grep -E "PORT|open|filtered|closed" | grep -v "Not shown")
    local web_servers=$(grep -A 30 "Scanning for web servers" "$LOG_FILE" | grep -E "Nmap scan report|80/tcp|443/tcp|8080/tcp|8443/tcp")
    local db_servers=$(grep -A 30 "Scanning for database servers" "$LOG_FILE" | grep -E "Nmap scan report|1433/tcp|3306/tcp|5432/tcp|27017/tcp|6379/tcp|9200/tcp")
    local vulnerabilities=$(grep -A 100 "Scanning .* for vulnerabilities" "$LOG_FILE" | grep -E "VULNERABLE|CVE-|exploit")
    local wireless=$(grep -A 30 "Scanning for available wireless connections" "$LOG_FILE" | grep -E "ESSID|Signal|Quality|Channel|SSID")

    echo "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Network Scan Report</title>
    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #3b82f6;
            --accent-color: #60a5fa;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --dark-color: #1e3a8a;
            --light-color: #f3f4f6;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
            background-color: #f9fafb;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: linear-gradient(135deg, var(--primary-color), var(--dark-color));
            color: white;
            padding: 20px;
            border-radius: 10px 10px 0 0;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .header h1 {
            margin: 0;
            font-size: 28px;
        }

        .header p {
            margin: 5px 0 0;
            opacity: 0.8;
        }

        .summary-box {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-item {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .summary-item h3 {
            margin-top: 0;
            font-size: 16px;
            color: #6b7280;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 8px;
        }

        .summary-item p {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .card {
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .card-header {
            padding: 15px 20px;
            background-color: var(--light-color);
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-header h2 {
            margin: 0;
            font-size: 18px;
            color: var(--dark-color);
        }

        .card-body {
            padding: 20px;
        }

        pre.code-block {
            background-color: #f8fafc;
            padding: 15px;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            overflow-x: auto;
            font-family: 'Courier New', Courier, monospace;
            font-size: 14px;
            white-space: pre-wrap;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }

        table th {
            background-color: var(--light-color);
            text-align: left;
            padding: 10px;
            font-weight: 600;
            border-bottom: 2px solid #e5e7eb;
        }

        table td {
            padding: 10px;
            border-bottom: 1px solid #e5e7eb;
        }

        table tr:nth-child(even) {
            background-color: #f8fafc;
        }

        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
            color: white;
        }

        .badge-success {
            background-color: var(--success-color);
        }

        .badge-danger {
            background-color: var(--danger-color);
        }

        .badge-warning {
            background-color: var(--warning-color);
        }

        .badge-info {
            background-color: var(--info-color);
        }

        .footer {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            color: #6b7280;
            font-size: 14px;
        }

        .expandable {
            cursor: pointer;
        }

        .expandable-content {
            display: none;
        }

        .expandable.active .expandable-content {
            display: block;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .summary-box {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Toggle expandable sections
            document.querySelectorAll('.expandable-header').forEach(header => {
                header.addEventListener('click', function() {
                    this.parentElement.classList.toggle('active');
                });
            });

            // Filter table data
            document.querySelectorAll('.filter-input').forEach(input => {
                input.addEventListener('keyup', function() {
                    const value = this.value.toLowerCase();
                    const table = this.closest('.card').querySelector('table');

                    table.querySelectorAll('tbody tr').forEach(row => {
                        const text = row.textContent.toLowerCase();
                        row.style.display = text.includes(value) ? '' : 'none';
                    });
                });
            });
        });
    </script>
</head>
<body>
    <div class=\"container\">
        <div class=\"header\">
            <h1>Network Scan Report</h1>
            <p>Generated on $(date +'%Y-%m-%d %H:%M:%S')</p>
        </div>

        <div class=\"summary-box\">
            <div class=\"summary-item\">
                <h3>Host IP</h3>
                <p>$host_ip</p>
            </div>
            <div class=\"summary-item\">
                <h3>Network</h3>
                <p>$network</p>
            </div>
            <div class=\"summary-item\">
                <h3>Default Gateway</h3>
                <p>$gateway</p>
            </div>
        </div>

        <!-- Live Hosts Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Live Hosts</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter hosts...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$live_hosts</pre>
            </div>
        </div>

        <!-- Port Scans Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Port Scan Results</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter ports...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$port_scans</pre>
            </div>
        </div>

        <!-- Web Servers Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Web Servers</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter web servers...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$web_servers</pre>
            </div>
        </div>

        <!-- Database Servers Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Database Servers</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter database servers...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$db_servers</pre>
            </div>
        </div>

        <!-- Vulnerabilities Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Vulnerabilities</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter vulnerabilities...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$vulnerabilities</pre>
            </div>
        </div>

        <!-- Wireless Connections Section -->
        <div class=\"card\">
            <div class=\"card-header\">
                <h2>Wireless Connections</h2>
                <input type=\"text\" class=\"filter-input\" placeholder=\"Filter wireless...\">
            </div>
            <div class=\"card-body\">
                <pre class=\"code-block\">$wireless</pre>
            </div>
        </div>

        <!-- Full Log Section -->
        <div class=\"card expandable\">
            <div class=\"card-header expandable-header\">
                <h2>Full Scan Log</h2>
                <span>Click to expand/collapse</span>
            </div>
            <div class=\"card-body expandable-content\">
                <pre class=\"code-block\">$(cat "$LOG_FILE")</pre>
            </div>
        </div>

        <div class=\"footer\">
            <p>Generated by NetScan Pro v2.0</p>
        </div>
    </div>
</body>
</html>" > "$report_file"

    log "${GREEN}[+] Enhanced visual report generated: $report_file${NC}"

    # Try to open the report in the default browser if supported
    if command -v xdg-open &> /dev/null; then
        xdg-open "$report_file" &> /dev/null &
    elif command -v open &> /dev/null; then
        open "$report_file" &> /dev/null &
    else
        log "${YELLOW}[!] Report created but could not open automatically. Please open manually: $report_file${NC}"
    fi
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