#!/bin/bash
#
# Dependency Installer for airhack-ng-v3
# Automatically installs required tools based on your Linux distribution
#
# Usage: sudo ./install_dependencies.sh
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AirHack-ng v3 Dependency Installer          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] This script must be run as root${NC}"
    echo -e "${YELLOW}[*] Please run: sudo $0${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Running as root${NC}\n"

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
        DISTRO_NAME=$PRETTY_NAME
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
        DISTRO_VERSION=$DISTRIB_RELEASE
        DISTRO_NAME=$DISTRIB_DESCRIPTION
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown Linux Distribution"
    fi
}

detect_distro

echo -e "${BLUE}[*] Detected OS: ${DISTRO_NAME}${NC}\n"

# Determine package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="apt update"
    INSTALL_CMD="apt install -y"
elif command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    UPDATE_CMD="apt-get update"
    INSTALL_CMD="apt-get install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="pacman -Sy"
    INSTALL_CMD="pacman -S --noconfirm"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="dnf check-update || true"
    INSTALL_CMD="dnf install -y"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    UPDATE_CMD="yum check-update || true"
    INSTALL_CMD="yum install -y"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    UPDATE_CMD="zypper refresh"
    INSTALL_CMD="zypper install -y"
else
    echo -e "${RED}[!] Could not detect package manager${NC}"
    echo -e "${YELLOW}[*] Please install dependencies manually:${NC}"
    echo -e "    - aircrack-ng"
    echo -e "    - iw"
    echo -e "    - iproute2 (provides 'ip' command)"
    echo -e "    - wireless-tools (optional)"
    exit 1
fi

echo -e "${GREEN}[✓] Package manager: $PKG_MANAGER${NC}\n"

# Define packages based on distribution
case $PKG_MANAGER in
    apt|apt-get)
        CORE_PACKAGES=(
            "aircrack-ng"
            "iw"
            "iproute2"
            "wireless-tools"
            "net-tools"
        )
        OPTIONAL_PACKAGES=(
            "wordlists"
            "konsole"
            "gnome-terminal"
            "xterm"
        )
        ;;
    pacman)
        CORE_PACKAGES=(
            "aircrack-ng"
            "iw"
            "iproute2"
            "wireless_tools"
        )
        OPTIONAL_PACKAGES=(
            "konsole"
            "gnome-terminal"
            "xterm"
        )
        ;;
    dnf|yum)
        CORE_PACKAGES=(
            "aircrack-ng"
            "iw"
            "iproute"
            "wireless-tools"
        )
        OPTIONAL_PACKAGES=(
            "konsole"
            "gnome-terminal"
            "xterm"
        )
        ;;
    zypper)
        CORE_PACKAGES=(
            "aircrack-ng"
            "iw"
            "iproute2"
            "wireless-tools"
        )
        OPTIONAL_PACKAGES=(
            "konsole"
            "gnome-terminal"
            "xterm"
        )
        ;;
esac

# Update package database
echo -e "${BLUE}[*] Updating package database...${NC}"
$UPDATE_CMD
echo -e "${GREEN}[✓] Package database updated${NC}\n"

# Install core packages
echo -e "${BLUE}[*] Installing core dependencies...${NC}\n"

FAILED_PACKAGES=()

for package in "${CORE_PACKAGES[@]}"; do
    echo -e "${YELLOW}[*] Installing: $package${NC}"

    if $INSTALL_CMD "$package" &> /tmp/install_log_$package.txt; then
        echo -e "${GREEN}[✓] Installed: $package${NC}"
    else
        echo -e "${RED}[✗] Failed to install: $package${NC}"
        FAILED_PACKAGES+=("$package")
        echo -e "${YELLOW}[*] See /tmp/install_log_$package.txt for details${NC}"
    fi
done

echo

# Verify aircrack-ng suite
echo -e "${BLUE}[*] Verifying aircrack-ng installation...${NC}"

AIRCRACK_TOOLS=("airmon-ng" "airodump-ng" "aireplay-ng" "aircrack-ng")
ALL_FOUND=1

for tool in "${AIRCRACK_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}[✓]${NC} $tool"
    else
        echo -e "${RED}[✗]${NC} $tool - NOT FOUND"
        ALL_FOUND=0
    fi
done

if [ $ALL_FOUND -eq 1 ]; then
    VERSION=$(aircrack-ng --help 2>&1 | head -n1 | grep -oP 'Aircrack-ng \K[0-9.]+' || echo "unknown")
    echo -e "${GREEN}[✓] Aircrack-ng suite installed (version: $VERSION)${NC}\n"
else
    echo -e "${RED}[!] Aircrack-ng suite incomplete${NC}\n"
fi

# Check network tools
echo -e "${BLUE}[*] Verifying network tools...${NC}"

NETWORK_TOOLS=("iw" "ip")

for tool in "${NETWORK_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}[✓]${NC} $tool"
    else
        echo -e "${RED}[✗]${NC} $tool - NOT FOUND"
    fi
done

echo

# Ask about optional packages
echo -e "${BLUE}[*] Optional packages available:${NC}"
echo -e "  1. Terminal emulators (for -k flag functionality)"
echo -e "  2. Wordlists (for WPA dictionary attacks)"
echo -e "  3. Both"
echo -e "  4. Skip optional packages"
echo

read -p "Select option [1-4]: " OPTIONAL_CHOICE

case $OPTIONAL_CHOICE in
    1)
        echo -e "\n${BLUE}[*] Installing terminal emulators...${NC}"
        for pkg in konsole gnome-terminal xterm; do
            if ! command -v "$pkg" &> /dev/null; then
                echo -e "${YELLOW}[*] Installing: $pkg${NC}"
                $INSTALL_CMD "$pkg" &> /dev/null && echo -e "${GREEN}[✓] Installed: $pkg${NC}" || echo -e "${YELLOW}[!] Failed: $pkg (non-critical)${NC}"
            else
                echo -e "${GREEN}[✓] Already installed: $pkg${NC}"
            fi
        done
        ;;
    2)
        echo -e "\n${BLUE}[*] Installing wordlists...${NC}"
        if [ "$PKG_MANAGER" = "apt" ] || [ "$PKG_MANAGER" = "apt-get" ]; then
            $INSTALL_CMD wordlists

            # Decompress rockyou.txt if it exists
            if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
                echo -e "${YELLOW}[*] Decompressing rockyou.txt...${NC}"
                gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
                echo -e "${GREEN}[✓] rockyou.txt decompressed${NC}"
            fi

            if [ -f /usr/share/wordlists/rockyou.txt ]; then
                SIZE=$(du -h /usr/share/wordlists/rockyou.txt | cut -f1)
                echo -e "${GREEN}[✓] rockyou.txt available ($SIZE)${NC}"
            fi
        else
            echo -e "${YELLOW}[!] Wordlists package not available for $PKG_MANAGER${NC}"
            echo -e "${YELLOW}[*] You can download rockyou.txt manually:${NC}"
            echo -e "    wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"
        fi
        ;;
    3)
        echo -e "\n${BLUE}[*] Installing terminal emulators and wordlists...${NC}"

        # Install terminals
        for pkg in konsole gnome-terminal xterm; do
            if ! command -v "$pkg" &> /dev/null; then
                echo -e "${YELLOW}[*] Installing: $pkg${NC}"
                $INSTALL_CMD "$pkg" &> /dev/null && echo -e "${GREEN}[✓] Installed: $pkg${NC}" || echo -e "${YELLOW}[!] Failed: $pkg (non-critical)${NC}"
            else
                echo -e "${GREEN}[✓] Already installed: $pkg${NC}"
            fi
        done

        # Install wordlists
        if [ "$PKG_MANAGER" = "apt" ] || [ "$PKG_MANAGER" = "apt-get" ]; then
            $INSTALL_CMD wordlists

            if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
                echo -e "${YELLOW}[*] Decompressing rockyou.txt...${NC}"
                gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
                echo -e "${GREEN}[✓] rockyou.txt decompressed${NC}"
            fi
        fi
        ;;
    4)
        echo -e "${YELLOW}[*] Skipping optional packages${NC}"
        ;;
    *)
        echo -e "${YELLOW}[!] Invalid choice, skipping optional packages${NC}"
        ;;
esac

echo

# Create airhack-ng directory
echo -e "${BLUE}[*] Creating working directory...${NC}"
WORK_DIR=$(eval echo ~$SUDO_USER)/airhack-ng

if [ ! -d "$WORK_DIR" ]; then
    mkdir -p "$WORK_DIR"
    chown $SUDO_USER:$SUDO_USER "$WORK_DIR"
    echo -e "${GREEN}[✓] Created: $WORK_DIR${NC}"
else
    echo -e "${GREEN}[✓] Already exists: $WORK_DIR${NC}"
fi

echo

# Check wireless adapters
echo -e "${BLUE}[*] Checking for wireless adapters...${NC}"

if command -v iw &> /dev/null; then
    WIRELESS_COUNT=$(iw dev 2>/dev/null | grep Interface | wc -l)

    if [ "$WIRELESS_COUNT" -gt 0 ]; then
        echo -e "${GREEN}[✓] Found $WIRELESS_COUNT wireless adapter(s):${NC}"
        iw dev 2>/dev/null | grep Interface | awk '{print "    - " $2}'

        # Check monitor mode support
        echo -e "\n${BLUE}[*] Checking monitor mode support...${NC}"
        for iface in $(iw dev 2>/dev/null | grep Interface | awk '{print $2}'); do
            PHY=$(iw dev "$iface" info | grep wiphy | awk '{print "phy"$2}')
            if iw phy "$PHY" info 2>/dev/null | grep -q "* monitor"; then
                echo -e "${GREEN}[✓]${NC} $iface - Monitor mode SUPPORTED"
            else
                echo -e "${RED}[✗]${NC} $iface - Monitor mode NOT supported"
            fi
        done
    else
        echo -e "${YELLOW}[!] No wireless adapters detected${NC}"
        echo -e "${YELLOW}[*] You may need an external USB WiFi adapter${NC}"
    fi
else
    echo -e "${YELLOW}[!] Cannot check wireless adapters (iw not available)${NC}"
fi

echo

# Kernel module check
echo -e "${BLUE}[*] Checking wireless drivers...${NC}"

if lsmod | grep -qE "^(mac80211|cfg80211)"; then
    echo -e "${GREEN}[✓] Wireless kernel modules loaded${NC}"
else
    echo -e "${YELLOW}[!] No wireless kernel modules detected${NC}"
fi

echo

# Final summary
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                INSTALLATION SUMMARY            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
    echo -e "${GREEN}[✓] All core dependencies installed successfully!${NC}\n"

    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Run system check:"
    echo -e "     ${YELLOW}./check-system.sh${NC}"
    echo
    echo -e "  2. View help:"
    echo -e "     ${YELLOW}sudo ./airhack-ng-v3 --help${NC}"
    echo
    echo -e "  3. Test with a scan:"
    echo -e "     ${YELLOW}sudo ./airhack-ng-v3 -a <your_wifi_interface> --scan${NC}"
    echo

    # Check if any terminal was installed
    if command -v konsole &> /dev/null || command -v gnome-terminal &> /dev/null || command -v xterm &> /dev/null; then
        echo -e "${GREEN}[✓] Terminal emulator available - you can use the -k flag${NC}"
    else
        echo -e "${YELLOW}[!] No terminal emulator found - -k flag won't work${NC}"
    fi

    # Check if wordlists are available
    if [ -f /usr/share/wordlists/rockyou.txt ]; then
        echo -e "${GREEN}[✓] Wordlist available at: /usr/share/wordlists/rockyou.txt${NC}"
    fi

else
    echo -e "${RED}[✗] Some packages failed to install:${NC}"
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo -e "    - $pkg"
    done
    echo
    echo -e "${YELLOW}[*] You may need to install these manually${NC}"
fi

echo

# Cleanup
rm -f /tmp/install_log_*.txt

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}⚠️  REMEMBER: Only test networks you own or have authorization to test!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Installation complete!${NC}\n"
