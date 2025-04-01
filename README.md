# NetScan Pro

NetScan Pro is an enhanced network scanning tool written in Bash that provides an interactive menu to perform a variety of network diagnostics. With visually attractive output and fun features like ASCII banners and cowsay messages, this tool is both functional and engaging.

## Features

- **Display Basic Network Info:**
  Automatically shows your host IP, default gateway, and network (CIDR notation).

- **Interactive Scanning Options:**
  - **Live Host Scan:** Detect active hosts on your local network using `nmap`.
  - **Port Scan:** Perform a detailed port scan on any host (includes service and OS detection; requires sudo).
  - **Traceroute:** Display the network path to a specific host.
  - **Ping Test:** Conduct a simple ping test to check connectivity.

- **Visual Enhancements:**
  - **ASCII Banner:** Uses `figlet` (with optional `lolcat` for color) for an eye-catching header.
  - **Fun Messages:** Displays a fun greeting using `cowsay`.

- **Logging:**
  All outputs are timestamped and saved to a log file for later review.

## Installation

### Dependencies

This tool relies on the following packages:

- `nmap`
- `traceroute`
- `figlet`
- `lolcat`
- `cowsay`

### Installation

Alternatively, you can install the required packages manually:
```bash
sudo apt-get update
```
```bash
sudo apt-get install nmap traceroute figlet lolcat cowsay
```

## Usage

1. **Make the Script Executable:**
   Ensure the script file `network_scan.sh` has execute permissions:
   ```bash
   chmod +x network_scan.sh
   ```

2. **Run the Script:**
   Execute the script:
   ```bash
   ./network_scan.sh
   ```

3. **Follow the Interactive Menu:**
   - **Option 1:** Scan for live hosts on your network.
   - **Option 2:** Perform a detailed port scan on a specific host.
   - **Option 3:** Run traceroute to a specific host.
   - **Option 4:** Ping a specific host.
   - **Option 5:** Exit the tool.

   All scan results and outputs will be logged to a file named similar to `network_scan_YYYYMMDD_HHMMSS.log`.

## Customization

Feel free to modify and extend the script to meet your specific needs. Contributions and suggestions are welcome!

## License

This tool is provided "as-is" without any warranty. Use it responsibly and at your own risk.
