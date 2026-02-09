#!/bin/bash
#
# Wordlist Downloader for AirHack-ng v3
# Downloads common password wordlists for WPA/WPA2 dictionary attacks
#
# Usage: sudo ./download_wordlists.sh
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Wordlist Downloader for AirHack-ng     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

# Create wordlists directory
WORDLIST_DIR="./wordlists"
mkdir -p "$WORDLIST_DIR"

echo -e "${BLUE}[*] Wordlists will be downloaded to: $WORDLIST_DIR${NC}\n"

# Check available disk space
AVAILABLE_SPACE=$(df -BG "$WORDLIST_DIR" | tail -1 | awk '{print $4}' | sed 's/G//')

if [ "$AVAILABLE_SPACE" -lt 20 ]; then
    echo -e "${YELLOW}[!] Warning: Less than 20GB free space available${NC}"
    echo -e "${YELLOW}[!] Some wordlists are very large${NC}\n"
fi

# Wordlist options
echo -e "${BLUE}Available wordlists:${NC}\n"
echo -e "  ${GREEN}1.${NC} rockyou.txt (14GB, 14M passwords) ${YELLOW}[Most Popular]${NC}"
echo -e "     - Most common wordlist for WPA cracking"
echo -e "     - Contains real-world passwords from data breaches"
echo -e ""
echo -e "  ${GREEN}2.${NC} Smaller wordlists (< 1GB total)"
echo -e "     - common-passwords.txt (~10MB)"
echo -e "     - top-10000.txt (~100KB)"
echo -e "     - WiFi-specific wordlists"
echo -e ""
echo -e "  ${GREEN}3.${NC} All wordlists (15GB+)"
echo -e "     - Complete collection for thorough testing"
echo -e ""
echo -e "  ${GREEN}4.${NC} Custom - Enter URL"
echo -e ""
echo -e "  ${GREEN}5.${NC} Skip - I'll download manually"
echo -e ""

read -p "Select option [1-5]: " CHOICE

download_file() {
    local url=$1
    local output=$2
    local description=$3

    echo -e "\n${BLUE}[*] Downloading: $description${NC}"

    if command -v wget &> /dev/null; then
        wget -q --show-progress "$url" -O "$output"
    elif command -v curl &> /dev/null; then
        curl -L --progress-bar "$url" -o "$output"
    else
        echo -e "${RED}[!] Neither wget nor curl found${NC}"
        echo -e "${YELLOW}[*] Please install wget: sudo apt install wget${NC}"
        return 1
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Downloaded: $output${NC}"

        # Decompress if needed
        if [[ "$output" == *.gz ]]; then
            echo -e "${YELLOW}[*] Decompressing...${NC}"
            gunzip -f "$output"
            echo -e "${GREEN}[✓] Decompressed${NC}"
        fi

        return 0
    else
        echo -e "${RED}[✗] Failed to download${NC}"
        return 1
    fi
}

case $CHOICE in
    1)
        echo -e "\n${BLUE}[*] Downloading rockyou.txt...${NC}"
        echo -e "${YELLOW}[*] This is a large file (14GB) and may take a while${NC}\n"

        # Check if system wordlist exists first
        if [ -f /usr/share/wordlists/rockyou.txt ]; then
            echo -e "${GREEN}[✓] Found rockyou.txt in /usr/share/wordlists/${NC}"
            read -p "Create symlink instead of downloading? [Y/n]: " SYMLINK
            if [[ "$SYMLINK" != "n" && "$SYMLINK" != "N" ]]; then
                ln -sf /usr/share/wordlists/rockyou.txt "$WORDLIST_DIR/rockyou.txt"
                echo -e "${GREEN}[✓] Symlink created${NC}"
                exit 0
            fi
        elif [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
            echo -e "${GREEN}[✓] Found rockyou.txt.gz in /usr/share/wordlists/${NC}"
            echo -e "${YELLOW}[*] Decompressing...${NC}"
            sudo gunzip /usr/share/wordlists/rockyou.txt.gz
            ln -sf /usr/share/wordlists/rockyou.txt "$WORDLIST_DIR/rockyou.txt"
            echo -e "${GREEN}[✓] Symlink created${NC}"
            exit 0
        fi

        # Download from GitHub mirror
        download_file \
            "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" \
            "$WORDLIST_DIR/rockyou.txt" \
            "rockyou.txt (14GB)"
        ;;

    2)
        echo -e "\n${BLUE}[*] Downloading smaller wordlists...${NC}\n"

        # Common passwords
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" \
            "$WORDLIST_DIR/common-1m.txt" \
            "Top 1M common passwords"

        # Top 10000
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt" \
            "$WORDLIST_DIR/top-10000.txt" \
            "Top 10000 passwords"

        # WiFi defaults
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt" \
            "$WORDLIST_DIR/wifi-wpa-top4800.txt" \
            "WiFi WPA top 4800"

        # Router defaults
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Default-Credentials/default-passwords.txt" \
            "$WORDLIST_DIR/default-passwords.txt" \
            "Default passwords"
        ;;

    3)
        echo -e "\n${BLUE}[*] Downloading complete wordlist collection...${NC}\n"

        # Rockyou
        if [ -f /usr/share/wordlists/rockyou.txt ]; then
            ln -sf /usr/share/wordlists/rockyou.txt "$WORDLIST_DIR/rockyou.txt"
            echo -e "${GREEN}[✓] Symlinked rockyou.txt${NC}"
        else
            download_file \
                "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" \
                "$WORDLIST_DIR/rockyou.txt" \
                "rockyou.txt (14GB)"
        fi

        # Common passwords
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" \
            "$WORDLIST_DIR/common-1m.txt" \
            "Common 1M passwords"

        # WiFi specific
        download_file \
            "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt" \
            "$WORDLIST_DIR/wifi-wpa.txt" \
            "WiFi WPA passwords"
        ;;

    4)
        echo -e ""
        read -p "Enter wordlist URL: " CUSTOM_URL
        read -p "Enter output filename: " CUSTOM_NAME

        download_file "$CUSTOM_URL" "$WORDLIST_DIR/$CUSTOM_NAME" "Custom wordlist"
        ;;

    5)
        echo -e "\n${YELLOW}[*] Skipping automatic download${NC}"
        echo -e "\n${BLUE}Manual download instructions:${NC}"
        echo -e ""
        echo -e "  ${GREEN}rockyou.txt:${NC}"
        echo -e "    wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"
        echo -e "    mv rockyou.txt $WORDLIST_DIR/"
        echo -e ""
        echo -e "  ${GREEN}SecLists (comprehensive):${NC}"
        echo -e "    git clone https://github.com/danielmiessler/SecLists.git"
        echo -e "    cp -r SecLists/Passwords/* $WORDLIST_DIR/"
        echo -e ""
        exit 0
        ;;

    *)
        echo -e "${RED}[!] Invalid choice${NC}"
        exit 1
        ;;
esac

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    SUMMARY                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

if [ -d "$WORDLIST_DIR" ] && [ "$(ls -A $WORDLIST_DIR 2>/dev/null)" ]; then
    echo -e "${GREEN}[✓] Wordlists downloaded successfully!${NC}\n"
    echo -e "${BLUE}Available wordlists:${NC}"

    for file in "$WORDLIST_DIR"/*; do
        if [ -f "$file" ]; then
            size=$(du -h "$file" | cut -f1)
            lines=$(wc -l < "$file" 2>/dev/null || echo "N/A")
            echo -e "  ${GREEN}$(basename "$file")${NC} - $size ($lines passwords)"
        fi
    done

    echo -e "\n${BLUE}Usage example:${NC}"
    echo -e "  sudo ./airhack-ng-v3 -e \"Network\" -i -4 --dict $WORDLIST_DIR/rockyou.txt"

else
    echo -e "${YELLOW}[!] No wordlists were downloaded${NC}"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Note: Larger wordlists = better coverage but longer crack time${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
