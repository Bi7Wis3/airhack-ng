# AirHack-ng - WiFi Security Auditing Wrapper

## ⚠️ LEGAL WARNING

**This tool is for AUTHORIZED SECURITY TESTING ONLY.**

- Only use on networks you own or have explicit written permission to test
- Unauthorized access to computer networks is illegal in most jurisdictions
- This is for educational purposes and legitimate penetration testing engagements
- You are responsible for ensuring you have proper authorization before use

## Version History

### v1.0 (December 2009)
- Original WEP cracking wrapper
- Basic functionality for fake auth, IV capture, ARP replay
- KDE Konsole integration
- Used deprecated ifconfig/iwconfig commands

### v2.0 (April 2010)
- Added WPA/WPA2 support
- Dictionary attack functionality
- WPA handshake capture
- MDOS (deauth) attacks

### v3.0 (February 2026) - CURRENT
Complete modernization for 2026:

**Major Updates:**
- ✅ Replaced deprecated commands (ifconfig → ip, iwconfig → iw)
- ✅ Dynamic interface detection (no hardcoded wlan0)
- ✅ Multi-terminal emulator support (Konsole, GNOME Terminal, xterm, terminator)
- ✅ Proper root/sudo checking
- ✅ Dependency verification on startup
- ✅ Color-coded output for better readability
- ✅ Improved error handling and validation
- ✅ Fixed bash syntax errors (& vs && in conditionals)
- ✅ Modern monitor mode handling
- ✅ Better file path handling
- ✅ Secure parameter parsing
- ✅ NetworkManager conflict handling

## Requirements

### Software
- **aircrack-ng suite** (airmon-ng, airodump-ng, aireplay-ng, aircrack-ng)
- **iw** (wireless configuration tool)
- **ip** (network configuration tool)
- **Root/sudo access**

### Hardware
- WiFi adapter with **monitor mode support**
- Recommended chipsets: Atheros, Ralink, Realtek (with proper drivers)
- **NOT compatible** with most built-in laptop WiFi cards

### Installation

**Automatic (Recommended):**
```bash
sudo ./install_dependencies.sh
```

The installer will:
- Detect your Linux distribution automatically
- Install all required packages
- Optionally install wordlists and terminal emulators
- Check wireless adapter compatibility
- Create the working directory

**Manual Installation (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install aircrack-ng iw iproute2 wireless-tools net-tools
```

**Manual Installation (Arch Linux):**
```bash
sudo pacman -S aircrack-ng iw iproute2 wireless_tools
```

**Manual Installation (Fedora/RHEL):**
```bash
sudo dnf install aircrack-ng iw iproute wireless-tools
```

## Quick Start

**1. Install dependencies:**
```bash
sudo ./install_dependencies.sh
```

**2. Check system compatibility:**
```bash
./check-system.sh
```

**3. Start using:**
```bash
sudo ./airhack-ng-v3 --help
```

## Usage

### 1. Initial Setup

**List available wireless interfaces:**
```bash
iw dev
```

**Scan for networks:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --scan
```

**Enable monitor mode:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --enable_monitor
```

### 2. WEP Attack (Legacy - WEP is deprecated)

**Setup and save configuration:**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -a wlan0 -c 6 \
  -b AA:BB:CC:DD:EE:FF -g --save
```

**Run complete WEP attack (in separate terminals):**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -i -k -1 -2 -3
```

**Extract key from captured data:**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -i --get_key
```

### 3. WPA/WPA2 Attack

**Setup configuration:**
```bash
sudo ./airhack-ng-v3 -e "TargetWPA" -a wlan0 -c 11 \
  -b 00:11:22:33:44:55 -s AA:BB:CC:DD:EE:FF -g --save
```

**Capture handshake:**
```bash
# Terminal 1: Start capture
sudo ./airhack-ng-v3 -e "TargetWPA" -i -k -2

# Terminal 2: Deauth to force handshake
sudo ./airhack-ng-v3 -e "TargetWPA" -i -5
```

**Dictionary attack:**
```bash
sudo ./airhack-ng-v3 -e "TargetWPA" -i -4 --dict /usr/share/wordlists/rockyou.txt
```

### 4. Utility Commands

**Show current configuration:**
```bash
sudo ./airhack-ng-v3 -e "TargetNetwork" -i --show
```

**List saved configurations:**
```bash
./airhack-ng-v3 -l
```

**Disable monitor mode (when done):**
```bash
sudo ./airhack-ng-v3 -a wlan0 --disable_monitor
```

## Parameters Reference

### Network Parameters
| Flag | Description | Example |
|------|-------------|---------|
| `-a` | WiFi adapter interface | `-a wlan0` |
| `-e` | Target ESSID (network name) | `-e "MyNetwork"` |
| `-b` | Target BSSID (AP MAC) | `-b AA:BB:CC:DD:EE:FF` |
| `-c` | WiFi channel | `-c 6` |
| `-s` | Client MAC address | `-s 11:22:33:44:55:66` |
| `-m` | Your MAC address | `-m 00:11:22:33:44:55` |
| `-g` | Auto-detect your MAC | `-g` |

### Actions
| Flag | Description |
|------|-------------|
| `--scan` | Scan for available networks |
| `-em, --enable_monitor` | Enable monitor mode |
| `-dm, --disable_monitor` | Disable monitor mode |
| `-1` | Fake authentication (WEP) |
| `-2` | Capture IVs/packets to file |
| `-3` | ARP replay attack |
| `-4` | Dictionary attack (WPA/WPA2) |
| `-5` | Capture WPA handshake (deauth) |
| `-6` | Deauth attack (MDOS) |
| `--get_key` | Extract key from capture |

### Options
| Flag | Description |
|------|-------------|
| `-k` | Open commands in new terminal tabs |
| `--save` | Save settings to file |
| `-i` | Import settings from saved file |
| `-l` | List saved configuration files |
| `--dict` | Dictionary file path |
| `--show` | Show current configuration |
| `-h, --help` | Display help message |

## Attack Workflow

### WEP Attack Flow
1. **Enable monitor mode** → `-em`
2. **Scan for target** → `--scan`
3. **Save configuration** → `-e -a -c -b -g --save`
4. **Fake authentication** → `-i -1`
5. **Capture IVs** → `-i -2`
6. **ARP replay** → `-i -3`
7. **Extract key** → `-i --get_key`

### WPA/WPA2 Attack Flow
1. **Enable monitor mode** → `-em`
2. **Scan for target** → `--scan`
3. **Save configuration** → `-e -a -c -b -s -g --save`
4. **Start capture** → `-i -2`
5. **Deauth client** → `-i -5` (forces handshake)
6. **Dictionary attack** → `-i -4 --dict wordlist.txt`

## Troubleshooting

### Monitor mode won't enable
```bash
# Kill interfering processes
sudo airmon-ng check kill

# Manually stop NetworkManager
sudo systemctl stop NetworkManager

# Try enabling again
sudo ./airhack-ng-v3 -a wlan0 -em
```

### No monitor interface found
```bash
# Check if your adapter supports monitor mode
iw list | grep -A 10 "Supported interface modes"

# Look for "* monitor" in the output
```

### Adapter not capturing packets
```bash
# Check if monitor interface is on correct channel
iw dev mon0 info

# Manually set channel
sudo iw dev mon0 set channel 6
```

### "Operation not permitted" errors
```bash
# Always run with sudo
sudo ./airhack-ng-v3 [options]
```

## File Structure

```
~/airhack-ng/
├── <ESSID>.net         # Saved configuration per network
└── <ESSID>-01.cap      # Captured packets/handshakes
```

## Changes from v1/v2

### Command Replacements
| Old (v1/v2) | New (v3) | Purpose |
|-------------|----------|---------|
| `ifconfig wlan0 down` | `ip link set wlan0 down` | Bring interface down |
| `iwconfig wlan0 mode monitor` | `iw dev wlan0 set type monitor` | Set monitor mode |
| `grep HWaddr` | `grep link/ether` | Get MAC address |
| Hardcoded `wlan0` | Dynamic detection | Support any interface |
| Hardcoded `konsole` | Multi-terminal support | Works on more systems |

### Bug Fixes
- **Line 97-101 (v1/v2)**: Fixed `&` → `&&` (logical AND instead of backgrounding)
- **Interface detection**: No longer assumes `wlan0` exists
- **Monitor interface**: Properly detects `mon0`, `wlan0mon`, etc.
- **Error handling**: Better validation before executing commands

## Common Wordlists for Dictionary Attacks

```bash
# Kali Linux / Parrot OS
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/dirb/common.txt

# Download rockyou.txt (Ubuntu/Debian)
sudo apt install wordlists
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
```

## Ethical Hacking Guidelines

1. **Always get written permission** before testing any network
2. **Document your authorization** (keep emails, contracts)
3. **Only test during agreed timeframes**
4. **Report findings responsibly** to network owners
5. **Don't access/modify/delete data** beyond scope of engagement
6. **Follow responsible disclosure** for any vulnerabilities found

## Modern WiFi Security Notes

- **WEP**: Completely broken, crackable in minutes (deprecated 2004)
- **WPA**: Deprecated, vulnerable to attacks (deprecated 2006)
- **WPA2**: Still secure with strong passwords (128-bit minimum recommended)
- **WPA3**: Most secure, resistant to offline dictionary attacks (2018+)

For authorized testing of modern networks, consider:
- WPA2/WPA3 handshake capture requires client deauthentication
- Strong passwords (15+ characters) are practically uncrackable
- Enterprise WPA2/WPA3 (802.1X) requires different attack vectors
- Many modern routers have deauth attack protections

## Resources

- **Aircrack-ng Documentation**: https://aircrack-ng.org/documentation.html
- **Wireless Adapter Compatibility**: https://aircrack-ng.org/doku.php?id=compatibility_drivers
- **Legal Information**: Research local laws regarding network security testing

## License

Published under the Free Public License (original v1/v2 license maintained).

## Credits

- **Original Author**: Bitwise Operator (2009-2010)
- **v3 Modernization**: Updated for 2026 compatibility
- **Underlying Tools**: Aircrack-ng team and contributors

---

**Remember: With great power comes great responsibility. Use wisely and legally.**
