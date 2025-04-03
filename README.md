# <div align="center"> 🔍 NetScan Pro - Network Discovery & Security Tool</div>

<div align="center">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Security-ED1C24?style=for-the-badge&logo=security&logoColor=white" alt="Security">
  <img src="https://img.shields.io/badge/Nmap-0E83CD?style=for-the-badge&logo=nmap&logoColor=white" alt="Nmap">
</div>

**NetScan Pro** is a powerful Bash-based network reconnaissance and security assessment toolkit designed for **Network Administrators, Security Professionals, and IT Enthusiasts**. This interactive command-line tool provides comprehensive network scanning capabilities with a **user-friendly interface** enhanced by color-coded outputs and visual elements.

<div align="center">
  <img src="assets/preview.png" alt="NetScan Pro Preview" width="700">
  <p><i>NetScan Pro interface with colorful output and interactive menu</i></p>
</div>

## <div align="center">🚀 Installation

### <div align="center">1. Quick Setup

```bash
# Clone the repository
git clone https://github.com/niladri-1/NetScan-Pro.git
cd NetScan-Pro

# Run the installer script (automatically installs dependencies)
chmod +x install.sh
sudo ./install.sh

# Start NetScan Pro
sudo ./network_scan.sh
```

### <div align="center">2. Manual Installation

If you prefer to install dependencies manually:

```bash
# Clone the repository
git clone https://github.com/niladri-1/NetScan-Pro.git
cd NetScan-Pro

# Install required packages
sudo apt-get install -y nmap traceroute figlet lolcat cowsay toilet nmcli iwlist iwconfig

# Make scripts executable
chmod +x network_scan.sh

# Run NetScan Pro
sudo ./network_scan.sh
```

## <div align="center">✨ Features

- **Network Discovery**
  - Live host detection
  - Comprehensive device enumeration
  - Gateway and subnet mapping

- **Port Scanning**
  - Quick (top 100 ports)
  - Standard (common ports with service detection)
  - Full (all 65535 ports with detailed OS and service detection)

- **Service Detection**
  - Web server discovery (HTTP/HTTPS)
  - Database server identification (MySQL, PostgreSQL, MongoDB, etc.)
  - Service version fingerprinting

- **Security Assessment**
  - Vulnerability scanning with CVE identification
  - Service weakness detection
  - Security posture evaluation

- **Wireless Network Analysis**
  - Wi-Fi network discovery
  - Signal strength measurement
  - Channel distribution analysis

- **Reporting**
  - Interactive HTML reports with filtering capabilities
  - Comprehensive logs with timestamps
  - Exportable results for documentation

### <div align="center">Common Use Cases</div>

- **Quick Network Audit**: Option 1 (Scan for live hosts) → Option 6 (Find web servers)
- **Detailed Host Analysis**: Option 4 (Standard port scan) → Option 8 (Vulnerability scan)
- **Complete Security Assessment**: Options 1 → 2 → 5 → 8 → 10 (Generate report)

## <div align="center">📁 Project Structure</div>

```
netscan-pro/
├── install.sh              # Dependency installer
├── network_scan.sh         # Main scanner script
├── README.md               # This documentation
├── results/                # Scan logs and results
└── Web Pages/              # Generated HTML reports
```

## <div align="center">🔧 Dependencies</div>

- **nmap**: Core scanning engine
- **traceroute**: Network path analysis
- **figlet**, **lolcat**, **toilet**: Terminal UI enhancements
- **nmcli**, **iwlist**, **iwconfig**: Wireless network tools

## <div align="center">⚠️ Ethical Usage Warning</div>

NetScan Pro is designed for legitimate network administration, security assessment, and educational purposes. Always:

- **Obtain proper authorization** before scanning any network
- **Respect privacy** and data protection regulations
- **Use responsibly** and follow local laws regarding network scanning

Unauthorized scanning of networks may be illegal and unethical.

## <div align="center">🤝 Contributing</div>

Contributions to NetScan Pro are welcome! If you'd like to help improve this tool:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## <div align="center">📜 License</div>

This project is distributed under the MIT License. See the LICENSE file for details.

## <div align="center">📞 Support</div>

For issues, questions, or feedback:
- Contact: [Linkedin](https://linkedin.com/in/niladri1)
- Open an [Portfolio](https://niladri1.vercel.app)
- Open an [Issue Pole](https://github.com/niladri-1/NetScan-Pro/issues)

---

<div align="center">
  <h4>Made with ❤️ for the security community. Stay Secure. Stay Informed. Happy Scanning!</h4>
</div>