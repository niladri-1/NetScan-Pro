# <div align="center">NetScan Pro</div>

NetScan Pro is an enhanced network scanning tool written in **Bash** that provides an interactive menu for various network diagnostics. It offers visually appealing output—featuring ASCII banners and fun cowsay messages—making it both practical and engaging.

## <div align="center">Preview</div>

<p align="center">
  <img src="https://github.com/niladri-1/NetScan-Pro/blob/main/assets/Preview.png" alt="NetScan Pro Preview" width="700">
</p>

> **Screenshot:** Here you can see NetScan Pro’s banner, network information display, and interactive menu.

## <div align="center">Features</div>

### 🔍 Network Discovery
- **Scan for live hosts on the network**
- **Perform a detailed network device discovery**

### 🔌 Port Scanning
- **Quick port scan** on a specific host
- **Standard port scan** on a specific host
- **Full port scan** on a specific host

### 🌐 Service Discovery
- **Find web servers** on the network
- **Find database servers** on the network
- **Find vulnerabilities** on a specific host

### 📡 Wireless
- **Find available wireless connections**

### 🛠️ Utilities
- **Generate an HTML report** from scan data
- **Clear the screen**
- **Exit the application**

### 📜 Logging
- **Timestamped logs** saved for easy review.

## <div align="center">Installation</div>

We provide an **install.sh** script that automates the setup:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/niladri-1/NetScan-Pro.git
   ```
   ```bash
   cd NetScan-Pro
   ```
2. **Run the Installation Script:**
   ```bash
   chmod +x install.sh && ./install.sh
   ```
3. **Run next time :**
   ```bash
   sudo ./network_scan.sh
   ```
   This script will:
   - Update your package lists.
   - Install required dependencies (`nmap`, `traceroute`, `figlet`, `lolcat`, `cowsay`).
   - Set execute permissions for the main script.
   - Automatically launch **NetScan Pro**.

Select an option and follow the prompts. Results are saved in a timestamped log file for future reference.

## <div align="center">Customization and Contributions</div>

Feel free to modify and extend NetScan Pro to suit your needs. Contributions, suggestions, and improvements are always welcome. If you encounter any issues or have questions, please [open an issue](https://github.com/niladri-1/NetScan-Pro/issues) on GitHub.

## <div align="center">License</div>

This project is provided **"as-is"** without any warranty. Use it responsibly and at your own risk.

---
<div align="center">

**Happy Scanning!**
Stay secure, stay informed.
</div>