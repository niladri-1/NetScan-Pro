# NetScan Pro

NetScan Pro is an enhanced network scanning tool written in **Bash** that provides an interactive menu for various network diagnostics. It offers visually appealing output—featuring ASCII banners and fun cowsay messages—making it both practical and engaging.

## Preview

<img src="https://github.com/niladri-1/NetScan-Pro/blob/main/assets/Preview.png" alt="NetScan Pro Preview" width="700">

> **Screenshot:** Here you can see NetScan Pro’s banner, network information display, and interactive menu.

## Features

- **Display Basic Network Info**
  Automatically shows your host IP, default gateway, and network (in CIDR notation).

- **Interactive Scanning Options**
  1. **Live Host Scan:** Detect active hosts on your local network using `nmap`.
  2. **Port Scan:** Perform a detailed port scan (includes service and OS detection; requires sudo).
  3. **Vulnerability Scan (Placeholder):** *(If you’ve integrated any vulnerability scanning, highlight it here.)*
  4. **Wireless Network Scan (Placeholder):** *(If added, mention it here.)*
  5. **Clear the Screen**
  6. **Exit**

- **Logging**
  All outputs are timestamped and saved to a log file for easy review.

## Installation

We provide an **install.sh** script that automates the setup:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/niladri-1/NetScan-Pro.git
   cd NetScan-Pro
   ```
2. **Run the Installation Script:**
   ```bash
   chmod +x install.sh && ./install.sh
   ```
   This script will:
   - Update your package lists.
   - Install required dependencies (`nmap`, `traceroute`, `figlet`, `lolcat`, `cowsay`).
   - Set execute permissions for the main script.
   - Automatically launch **NetScan Pro**.

Select an option and follow the prompts. Results are saved in a timestamped log file for future reference.

## Customization and Contributions

Feel free to modify and extend NetScan Pro to suit your needs. Contributions, suggestions, and improvements are always welcome. If you encounter any issues or have questions, please [open an issue](https://github.com/niladri-1/NetScan-Pro/issues) on GitHub.

## License

This project is provided **"as-is"** without any warranty. Use it responsibly and at your own risk.

---

**Happy Scanning!**
Stay secure, stay informed.