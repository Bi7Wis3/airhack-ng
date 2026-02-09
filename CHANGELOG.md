# Changelog

## [3.0] - 2026-02-09

### Major Modernization Release

#### Added
- ✅ Root privilege checking with helpful sudo instructions
- ✅ Automatic dependency verification on startup
- ✅ Multi-terminal emulator support (konsole, gnome-terminal, xterm, terminator)
- ✅ Color-coded output (red=errors, green=success, yellow=warnings, blue=info)
- ✅ Dynamic wireless interface detection
- ✅ Automatic monitor interface detection (mon0, wlan0mon, etc.)
- ✅ NetworkManager conflict handling (airmon-ng check kill)
- ✅ Comprehensive README with examples and troubleshooting
- ✅ **install_dependencies.sh** - Automatic dependency installer for multiple distros
- ✅ **check-system.sh** - System compatibility verification tool
- ✅ Legal warnings and ethical hacking guidelines
- ✅ File existence validation before operations
- ✅ Better capture file handling (.cap format instead of .ivs)
- ✅ Improved WPA handshake capture workflow
- ✅ Dictionary file validation

#### Changed
- 🔧 Replaced `ifconfig` with `ip` command
- 🔧 Replaced `iwconfig` with `iw` command
- 🔧 Monitor mode now uses `airmon-ng` API properly
- 🔧 MAC address detection uses modern `ip link` format
- 🔧 Interface names no longer hardcoded (was wlan0/wlp2s0)
- 🔧 Settings file parsing completely rewritten for safety
- 🔧 Terminal detection now automatic (no konsole requirement)
- 🔧 Improved command-line parameter parsing
- 🔧 Better error messages with context
- 🔧 More user-friendly confirmation prompts
- 🔧 Output files now in standard .cap format

#### Fixed
- 🐛 **CRITICAL**: Lines 97-101 bash syntax error (`&` → `&&`)
- 🐛 Quote all variables to prevent word splitting
- 🐛 Proper array handling for ARGS
- 🐛 Monitor interface detection logic
- 🐛 File path handling with spaces
- 🐛 Settings file sourcing (was unsafe)
- 🐛 MAC address regex for modern systems
- 🐛 Dictionary attack capture file path
- 🐛 WPA handshake deauth targeting (-c instead of -h)

#### Removed
- ❌ Hardcoded `wlan0` and `wlp2s0` references
- ❌ Hardcoded `konsole` requirement
- ❌ Unsafe `eval` and `set --` usage in settings parsing
- ❌ Deprecated `dcop` call (line 237 in v1)
- ❌ Hardcoded `mon0` interface assumptions

#### Security
- 🔒 Added authorization warnings throughout
- 🔒 Safer file parsing (no arbitrary code execution)
- 🔒 Input validation for all parameters
- 🔒 Quoted all variable expansions
- 🔒 Root privilege verification

#### Compatibility
- 📱 Works on Ubuntu 20.04+ / Debian 11+
- 📱 Works on Kali Linux 2020+
- 📱 Works on Arch Linux (current)
- 📱 Compatible with GNOME, KDE, XFCE, and terminal-only systems
- 📱 Supports systemd-based distributions

---

## [2.0] - 2010-04-14

### Added
- WPA/WPA2 attack support
- Dictionary attack functionality (`-4`)
- WPA handshake capture (`-5`)
- MDOS/deauth attack (`-6`)
- `--dict` parameter for wordlist specification
- WPA-specific examples in help text

### Changed
- Updated help text with WPA workflows
- Interface from `wlan0` to `wlp2s0` (tested on Kubuntu 9.10)
- Tested with b43 (Broadcom 4312) driver

### Notes
- Tested under Kubuntu 9.10
- Broadcom 4312 (b43 driver) confirmed working

---

## [1.0] - 2010-01-10

### Initial Release

#### Features
- WEP network security auditing
- Fake authentication attacks
- IV packet capture
- ARP replay attacks
- Automatic key extraction
- Settings save/load functionality
- KDE Konsole integration
- Monitor mode management

#### Known Issues
- Minor bugs with monitor mode (noted in comments)
- Line 237: Random `dcop kmix` call (likely copy/paste error)

#### Technology
- Bash shell script
- Aircrack-ng suite wrapper
- ifconfig/iwconfig-based networking
- Tested on Ubuntu/Kubuntu 9.10 era systems

---

## Version Comparison Summary

| Feature | v1.0 (2010) | v2.0 (2010) | v3.0 (2026) |
|---------|-------------|-------------|-------------|
| **WEP Attacks** | ✅ | ✅ | ✅ |
| **WPA/WPA2 Attacks** | ❌ | ✅ | ✅ |
| **Modern Commands** | ❌ | ❌ | ✅ |
| **Dynamic Interface Detection** | ❌ | ❌ | ✅ |
| **Multi-Terminal Support** | konsole only | konsole only | All major terminals |
| **Color Output** | Minimal | Minimal | Full color coding |
| **Dependency Checking** | ❌ | ❌ | ✅ |
| **Root Checking** | ❌ | ❌ | ✅ |
| **Error Handling** | Basic | Basic | Comprehensive |
| **Works on Modern Linux** | ❌ | ❌ | ✅ |
| **Bash Syntax Bugs** | ❌ (`&` bug) | ❌ (`&` bug) | ✅ Fixed |

## Migration Guide: v1/v2 → v3

### Command Changes
```bash
# v1/v2: Hardcoded interface
./airhack-ng-v1 -a wlan0 -e "Network" ...

# v3: Any interface works
./airhack-ng-v3 -a wlan0 -e "Network" ...
./airhack-ng-v3 -a wlp3s0 -e "Network" ...  # Also works
```

### Settings Files
Settings files (.net) from v1/v2 are **compatible** with v3! No migration needed.

### Monitor Mode
```bash
# v1/v2: Manual ifconfig/iwconfig
# (Often failed on modern systems)

# v3: Automatic airmon-ng integration
sudo ./airhack-ng-v3 -a wlan0 -em
# Handles NetworkManager conflicts automatically
```

### Capture Files
- v1/v2: Created `.ivs` files
- v3: Creates `.cap` files (more compatible)
- Both work with aircrack-ng

### Breaking Changes
- None! v3 is backward compatible with v1/v2 saved settings
- Old `.ivs` files still work with `--get_key`
- Command-line syntax unchanged

---

## Future Considerations (v4.0?)

Potential improvements for a future release:
- [ ] WPA3 support (requires newer aircrack-ng)
- [ ] Automatic wordlist download
- [ ] Integration with online hash databases
- [ ] GUI mode option
- [ ] Progress bars for long-running operations
- [ ] Bluetooth attack support
- [ ] PMKID attack (WPA2 without client)
- [ ] Config file format (YAML/JSON instead of custom)
- [ ] Logging to file
- [ ] Integration with Wireshark for analysis
- [ ] Docker container for easy deployment
- [ ] RESTful API for automation

---

**Note**: Always ensure you have proper authorization before performing any security testing.
