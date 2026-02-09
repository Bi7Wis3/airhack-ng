#!/bin/bash
#
# System Compatibility Check for airhack-ng-v3
# Run this to verify your system is ready for WiFi security testing
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AirHack-ng v3 System Compatibility Check    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

ERRORS=0
WARNINGS=0

# Check if running as root
echo -e "${BLUE}[*] Checking privileges...${NC}"
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Not running as root (this is OK for system check)${NC}"
    echo -e "${YELLOW}    Remember to use 'sudo' when running airhack-ng-v3${NC}\n"
else
    echo -e "${GREEN}[✓] Running as root${NC}\n"
fi

# Check required commands
echo -e "${BLUE}[*] Checking required tools...${NC}"

REQUIRED_TOOLS=(
    "airmon-ng:aircrack-ng"
    "airodump-ng:aircrack-ng"
    "aireplay-ng:aircrack-ng"
    "aircrack-ng:aircrack-ng"
    "iw:iw"
    "ip:iproute2"
)

for tool_pkg in "${REQUIRED_TOOLS[@]}"; do
    IFS=':' read -r tool pkg <<< "$tool_pkg"
    if command -v "$tool" &> /dev/null; then
        version=$(aircrack-ng --help 2>&1 | head -n1 | grep -oP 'Aircrack-ng \K[0-9.]+' || echo "unknown")
        echo -e "${GREEN}[✓]${NC} $tool (package: $pkg)"
    else
        echo -e "${RED}[✗]${NC} $tool - NOT FOUND (install: sudo apt install $pkg)"
        ((ERRORS++))
    fi
done
echo

# Check optional terminal emulators
echo -e "${BLUE}[*] Checking terminal emulators (for -k option)...${NC}"
TERMINAL_FOUND=0

TERMINALS=("konsole" "gnome-terminal" "xterm" "terminator")
for term in "${TERMINALS[@]}"; do
    if command -v "$term" &> /dev/null; then
        echo -e "${GREEN}[✓]${NC} $term"
        TERMINAL_FOUND=1
    fi
done

if [ $TERMINAL_FOUND -eq 0 ]; then
    echo -e "${YELLOW}[!] No supported terminal emulator found${NC}"
    echo -e "${YELLOW}    The -k option won't work (not critical)${NC}"
    ((WARNINGS++))
fi
echo

# Check for wireless interfaces
echo -e "${BLUE}[*] Checking wireless interfaces...${NC}"

if command -v iw &> /dev/null; then
    WIRELESS_IFACES=$(iw dev 2>/dev/null | grep Interface | awk '{print $2}')

    if [ -z "$WIRELESS_IFACES" ]; then
        echo -e "${RED}[✗] No wireless interfaces found${NC}"
        echo -e "${YELLOW}    Make sure you have a WiFi adapter connected${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}[✓] Wireless interfaces found:${NC}"
        for iface in $WIRELESS_IFACES; do
            echo -e "    - ${GREEN}$iface${NC}"

            # Check if interface supports monitor mode
            if iw phy $(iw dev "$iface" info | grep wiphy | awk '{print "phy"$2}') info 2>/dev/null | grep -q "* monitor"; then
                echo -e "      ${GREEN}└─ Monitor mode: SUPPORTED${NC}"
            else
                echo -e "      ${RED}└─ Monitor mode: NOT SUPPORTED${NC}"
                echo -e "         ${YELLOW}This adapter cannot be used for packet injection${NC}"
                ((WARNINGS++))
            fi
        done
    fi
else
    echo -e "${YELLOW}[!] Cannot check wireless interfaces (iw not installed)${NC}"
    ((WARNINGS++))
fi
echo

# Check for monitor mode interfaces
echo -e "${BLUE}[*] Checking for active monitor mode interfaces...${NC}"
MON_IFACES=$(iw dev 2>/dev/null | grep -A 1 "type monitor" | grep Interface | awk '{print $2}')

if [ -n "$MON_IFACES" ]; then
    echo -e "${GREEN}[✓] Monitor mode interfaces active:${NC}"
    for iface in $MON_IFACES; do
        echo -e "    - ${GREEN}$iface${NC}"
    done
    echo -e "${YELLOW}[!] You may want to disable these before starting (use -dm)${NC}"
else
    echo -e "${YELLOW}[•] No monitor mode interfaces active (normal state)${NC}"
fi
echo

# Check NetworkManager
echo -e "${BLUE}[*] Checking NetworkManager status...${NC}"
if systemctl is-active --quiet NetworkManager 2>/dev/null; then
    echo -e "${YELLOW}[!] NetworkManager is running${NC}"
    echo -e "${YELLOW}    This may interfere with monitor mode${NC}"
    echo -e "${YELLOW}    airhack-ng-v3 will handle this automatically${NC}"
    ((WARNINGS++))
elif service network-manager status &>/dev/null; then
    echo -e "${YELLOW}[!] NetworkManager is running (sysvinit)${NC}"
    echo -e "${YELLOW}    This may interfere with monitor mode${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}[✓] NetworkManager not interfering${NC}"
fi
echo

# Check wordlists (for dictionary attacks)
echo -e "${BLUE}[*] Checking for common wordlists...${NC}"
WORDLISTS=(
    "/usr/share/wordlists/rockyou.txt"
    "/usr/share/wordlists/rockyou.txt.gz"
    "/usr/share/dict/words"
)

WORDLIST_FOUND=0
for wl in "${WORDLISTS[@]}"; do
    if [ -f "$wl" ]; then
        size=$(du -h "$wl" | cut -f1)
        echo -e "${GREEN}[✓]${NC} $wl ($size)"
        WORDLIST_FOUND=1
    fi
done

if [ $WORDLIST_FOUND -eq 0 ]; then
    echo -e "${YELLOW}[!] No common wordlists found${NC}"
    echo -e "${YELLOW}    For WPA cracking, install: sudo apt install wordlists${NC}"
    echo -e "${YELLOW}    Then unzip: sudo gunzip /usr/share/wordlists/rockyou.txt.gz${NC}"
    ((WARNINGS++))
fi
echo

# Check kernel version
echo -e "${BLUE}[*] System information...${NC}"
echo -e "    Kernel: $(uname -r)"
echo -e "    OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "    Architecture: $(uname -m)"
echo

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    SUMMARY                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}[✓] System is ready for airhack-ng-v3!${NC}\n"
    echo -e "Next steps:"
    echo -e "  1. Run: ${YELLOW}sudo ./airhack-ng-v3 --help${NC}"
    echo -e "  2. Scan: ${YELLOW}sudo ./airhack-ng-v3 -a wlan0 --scan${NC}"
    echo -e "  3. Enable monitor: ${YELLOW}sudo ./airhack-ng-v3 -a wlan0 -em${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}[!] System is usable with $WARNINGS warning(s)${NC}\n"
    echo -e "You can proceed, but some features may not work optimally."
else
    echo -e "${RED}[✗] System has $ERRORS error(s) and $WARNINGS warning(s)${NC}\n"
    echo -e "Please resolve the errors above before using airhack-ng-v3."
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}⚠️  REMEMBER: Only test networks you own or have authorization to test!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

exit $ERRORS
