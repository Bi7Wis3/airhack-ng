# AirHack-ng v3 - WiFi Security Auditing Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/Version-3.0-orange.svg)]()

A modernized Bash wrapper for the [Aircrack-ng](https://aircrack-ng.org/) suite, designed for **authorized** WiFi security testing and penetration testing engagements.

```
╔════════════════════════════════════════════════╗
║   AirHack-ng v3 - WiFi Security Auditing      ║
║   Original: 2009-2010 | Modernized: 2026      ║
╚════════════════════════════════════════════════╝
```

## ⚠️ Legal Warning

**FOR AUTHORIZED SECURITY TESTING ONLY**

This tool is designed for legitimate security testing purposes. Unauthorized access to computer networks is illegal and punishable under laws worldwide including:
- Computer Fraud and Abuse Act (CFAA) - USA
- Computer Misuse Act - UK
- EU Directive 2013/40/EU - Europe

**Only use this tool on:**
- ✅ Networks you own
- ✅ Networks with explicit written permission
- ✅ Authorized penetration testing engagements
- ✅ Educational lab environments

**You are solely responsible for ensuring legal authorization before use.**

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/airhack-ng.git
cd airhack-ng

# 2. Install dependencies
sudo ./install_dependencies.sh

# 3. Download wordlists (optional, for WPA cracking)
./download_wordlists.sh

# 4. Check system compatibility
./check-system.sh

# 5. Start using
sudo ./airhack-ng-v3 --help
```

## ✨ Features

### v3.0 (2026) - Complete Modernization
- ✅ **Modern Linux compatibility** - Works on Ubuntu 20.04+, Arch, Fedora, Debian
- ✅ **Dynamic interface detection** - No hardcoded interface names
- ✅ **Multi-distro support** - Automatic package manager detection
- ✅ **Modern network commands** - Uses `ip` and `iw` instead of deprecated `ifconfig`/`iwconfig`
- ✅ **Multi-terminal support** - Works with GNOME Terminal, Konsole, xterm, terminator
- ✅ **Color-coded output** - Easy-to-read status messages
- ✅ **Automated setup** - One-command dependency installation
- ✅ **Comprehensive documentation** - Detailed guides and examples

### Attack Capabilities
- 🔓 **WEP Cracking** - Fake auth, IV capture, ARP replay
- 🔐 **WPA/WPA2 Handshake Capture** - Deauth attacks, handshake validation
- 📖 **Dictionary Attacks** - Support for custom wordlists
- 📡 **Network Scanning** - Identify targets and connected clients
- 💾 **Configuration Persistence** - Save/load target settings

## 📋 Requirements

### Software
- Linux (Ubuntu/Debian/Arch/Fedora/Kali)
- Bash 4.0+
- Aircrack-ng suite
- iw (wireless tools)
- iproute2 (ip command)

### Hardware
- WiFi adapter with **monitor mode support**
- Recommended: Alfa AWUS036ACH, TP-Link TL-WN722N v1

## 📦 Installation

### Automatic (Recommended)

```bash
sudo ./install_dependencies.sh
```

Supports:
- Ubuntu/Debian (apt)
- Arch Linux (pacman)
- Fedora/RHEL (dnf/yum)
- openSUSE (zypper)

### Manual Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install aircrack-ng iw iproute2 wireless-tools
```

**Arch Linux:**
```bash
sudo pacman -S aircrack-ng iw iproute2 wireless_tools
```

**Fedora/RHEL:**
```bash
sudo dnf install aircrack-ng iw iproute wireless-tools
```

## 📖 Usage

### Basic Workflow

**1. Enable monitor mode:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --enable_monitor
```

**2. Scan for networks:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --scan
```

**3. Save target configuration:**
```bash
sudo ./airhack-ng-v3 \
  -e "TargetNetwork" \
  -a wlan0 \
  -c 6 \
  -b AA:BB:CC:DD:EE:FF \
  -s 11:22:33:44:55:66 \
  -g \
  --save
```

**4. Capture WPA handshake:**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -i -k -2 -5
```

**5. Dictionary attack:**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -i -4 --dict wordlists/rockyou.txt
```

### Command Reference

| Flag | Description |
|------|-------------|
| `-a <iface>` | WiFi adapter interface |
| `-e <essid>` | Target network name (ESSID) |
| `-b <bssid>` | Target router MAC (BSSID) |
| `-c <channel>` | WiFi channel number |
| `-s <mac>` | Client MAC address |
| `-g` | Auto-detect your MAC |
| `-k` | Open in separate terminal tabs |
| `--save` | Save configuration |
| `-i` | Import saved configuration |
| `-1` | Fake authentication (WEP) |
| `-2` | Capture packets |
| `-3` | ARP replay attack (WEP) |
| `-4` | Dictionary attack (WPA) |
| `-5` | WPA handshake capture |
| `-6` | Deauth attack (MDOS) |
| `--get_key` | Extract key from capture |
| `-em` | Enable monitor mode |
| `-dm` | Disable monitor mode |

## 📚 Documentation

| File | Description |
|------|-------------|
| [GETTING_STARTED.md](GETTING_STARTED.md) | Step-by-step tutorial |
| [README.md](README.md) | Full documentation |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

## 🎯 Use Cases

### 1. Personal Network Security Audit
Test the strength of your own WiFi password:
```bash
sudo ./airhack-ng-v3 -e "MyNetwork" -a wlan0 -c 6 -b XX:XX:XX:XX:XX:XX -g --save
sudo ./airhack-ng-v3 -e "MyNetwork" -i -k -2 -5
sudo ./airhack-ng-v3 -e "MyNetwork" -i -4 --dict wordlists/rockyou.txt
```

### 2. Penetration Testing Engagement
**With proper authorization:**
```bash
# Document authorization first!
sudo ./airhack-ng-v3 -a wlan0 --scan
# Identify target, save config, perform testing
# Report findings professionally
```

### 3. Educational Lab
Set up a test environment with your own router:
```bash
# Configure old router with known weak password
# Practice WPA cracking techniques
# Learn about WiFi security
```

## 🛠️ Tools Included

| Tool | Purpose |
|------|---------|
| `airhack-ng-v3` | Main automation script |
| `install_dependencies.sh` | Auto-installer for all platforms |
| `download_wordlists.sh` | Wordlist downloader |
| `check-system.sh` | System compatibility checker |

## 🔄 Version History

### v3.0 (2026) - Major Modernization
- Complete rewrite for modern Linux systems
- Multi-distribution support
- Automated installation and setup
- Improved error handling and validation
- Color-coded terminal output
- Comprehensive documentation

### v2.0 (2010)
- Added WPA/WPA2 support
- Dictionary attack functionality
- Multiple attack modes

### v1.0 (2010)
- Initial release
- WEP cracking support

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

**Please ensure:**
- Code follows bash best practices
- Scripts are tested on multiple distributions
- Documentation is updated
- Legal/ethical guidelines are maintained

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Important:** This license applies to the software code only. Users are solely responsible for ensuring they have proper authorization before using this tool for any security testing.

## 🙏 Credits

- **Original Author:** Bitwise Operator (2009-2010)
- **v3 Modernization:** 2026
- **Underlying Tools:** [Aircrack-ng team](https://aircrack-ng.org/)

## 🔗 Resources

- [Aircrack-ng Documentation](https://aircrack-ng.org/documentation.html)
- [WiFi Adapter Compatibility](https://aircrack-ng.org/doku.php?id=compatibility_drivers)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## ⚡ Troubleshooting

### Monitor mode won't enable
```bash
sudo airmon-ng check kill
sudo systemctl stop NetworkManager
sudo ./airhack-ng-v3 -a wlan0 -em
```

### No wireless interfaces found
- Ensure WiFi adapter is connected
- Check if it supports monitor mode: `iw list | grep monitor`
- Consider external USB WiFi adapter (Alfa AWUS036ACH recommended)

### Handshake not capturing
- Verify correct channel with `-c` flag
- Ensure client is connected (check with scan)
- Get closer to target AP
- Try deauth multiple times

See [GETTING_STARTED.md](GETTING_STARTED.md) for comprehensive troubleshooting.

## 📧 Contact & Support

- **Issues:** Use GitHub Issues for bug reports
- **Discussions:** GitHub Discussions for questions
- **Security:** Report vulnerabilities privately

---

<div align="center">

**⚠️ Remember: Only use on networks you own or have explicit authorization to test ⚠️**

Made with 🔒 for ethical hackers and security professionals

[Report Bug](https://github.com/yourusername/airhack-ng/issues) · [Request Feature](https://github.com/yourusername/airhack-ng/issues) · [Documentation](README.md)

</div>
