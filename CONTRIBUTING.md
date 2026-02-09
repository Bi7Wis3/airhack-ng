# Contributing to AirHack-ng

Thank you for considering contributing to AirHack-ng! This document provides guidelines for contributing to the project.

## 🎯 How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [existing issues](https://github.com/yourusername/airhack-ng/issues)
- Run `./check-system.sh` to verify your setup
- Test with the latest version from `main` branch

**When submitting a bug report, include:**
- Your Linux distribution and version
- Output of `./check-system.sh`
- Steps to reproduce the issue
- Expected vs actual behavior
- Relevant logs or error messages
- WiFi adapter model (if hardware-related)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use GitHub Issues with the "enhancement" label
- Clearly describe the feature and its benefits
- Explain why it would be useful to most users
- Provide examples of how it would work

### Pull Requests

**Good pull requests include:**
1. Clear description of the problem and solution
2. Relevant issue number (if applicable)
3. Testing on multiple distributions
4. Updated documentation
5. Code that follows project style

## 🔧 Development Setup

### Prerequisites

```bash
# Clone your fork
git clone https://github.com/yourusername/airhack-ng.git
cd airhack-ng

# Install dependencies
sudo ./install_dependencies.sh

# Install development tools
sudo apt install shellcheck  # For bash linting
```

### Testing Your Changes

**Test on multiple distributions:**
- Ubuntu 22.04+ LTS
- Debian 11+
- Arch Linux (current)
- Kali Linux (current)
- Fedora 38+

**Run checks:**
```bash
# Syntax check all scripts
shellcheck airhack-ng-v3
shellcheck install_dependencies.sh
shellcheck check-system.sh
shellcheck download_wordlists.sh

# Test installation
sudo ./install_dependencies.sh

# Test system check
./check-system.sh

# Test basic functionality
sudo ./airhack-ng-v3 --help
```

## 📝 Coding Standards

### Bash Style Guide

**General Rules:**
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 100 characters
- Use `#!/bin/bash` shebang (not `/bin/sh`)
- Quote all variables: `"$VARIABLE"`
- Use `[[` instead of `[` for tests
- Use `$()` instead of backticks

**Function Naming:**
```bash
# Good
function check_dependencies() {
    local dep=$1
    # ...
}

# Avoid
function CheckDependencies() {  # Don't use CamelCase
    DEP=$1  # Use local variables
    # ...
}
```

**Variable Naming:**
```bash
# Good
GLOBAL_CONSTANT="value"  # All caps for globals
local_variable="value"   # lowercase for locals

# Avoid
globalVariable="value"   # Don't use camelCase
```

**Error Handling:**
```bash
# Always check return codes
if ! command; then
    echo -e "${RED}[!] Error message${NC}"
    return 1
fi

# Use proper exit codes
exit 0  # Success
exit 1  # General error
```

**Comments:**
```bash
# Good: Explain WHY, not WHAT
# Disable NetworkManager to prevent interference with monitor mode
sudo systemctl stop NetworkManager

# Avoid: Redundant comments
# Stop NetworkManager
sudo systemctl stop NetworkManager
```

## 🎨 Color Output

Use consistent color coding:
```bash
RED='\033[0;31m'      # Errors
GREEN='\033[0;32m'    # Success
YELLOW='\033[1;33m'   # Warnings
BLUE='\033[0;34m'     # Info
NC='\033[0m'          # No Color

echo -e "${RED}[!] Error${NC}"
echo -e "${GREEN}[✓] Success${NC}"
echo -e "${YELLOW}[!] Warning${NC}"
echo -e "${BLUE}[*] Info${NC}"
```

## 📚 Documentation

**Update documentation when:**
- Adding new features
- Changing command-line arguments
- Modifying installation process
- Adding new dependencies

**Documentation files:**
- `README.md` - Main documentation
- `README_GITHUB.md` - GitHub landing page
- `GETTING_STARTED.md` - Tutorial
- `CHANGELOG.md` - Version history
- Code comments - Explain complex logic

## 🧪 Testing Checklist

Before submitting a PR, verify:

- [ ] Code passes `shellcheck` with no errors
- [ ] Tested on at least 2 different distributions
- [ ] All existing features still work
- [ ] New features are documented
- [ ] README.md updated if needed
- [ ] CHANGELOG.md updated
- [ ] No hardcoded paths or interface names
- [ ] Error messages are clear and helpful
- [ ] Root permission check included where needed
- [ ] Color output is consistent
- [ ] Scripts are executable (`chmod +x`)

## 🔒 Security Considerations

**Important guidelines:**

1. **Never include actual passwords or keys**
2. **Don't hardcode sensitive information**
3. **Validate all user input**
4. **Quote all variables to prevent injection**
5. **Check file permissions before operations**
6. **Use secure temporary files**

**Example:**
```bash
# Good
read -p "Enter network name: " ESSID
if [[ -z "$ESSID" ]]; then
    echo "Error: ESSID required"
    exit 1
fi

# Bad
ESSID=$1  # No validation
eval "aircrack-ng $ESSID"  # Command injection risk!
```

## 🌟 Feature Development

**Before starting a major feature:**

1. Open an issue to discuss it
2. Get feedback from maintainers
3. Create a feature branch
4. Develop incrementally
5. Write tests/documentation as you go
6. Submit PR when ready

**Branch naming:**
```
feature/wpa3-support
bugfix/monitor-mode-detection
docs/installation-guide
```

## 📋 Commit Messages

**Format:**
```
type: Short description (50 chars or less)

Longer explanation if needed (wrap at 72 chars).
Explain WHAT changed and WHY, not HOW.

Fixes #123
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style (formatting, no logic change)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

**Examples:**
```
feat: Add WPA3 support to capture mode

Implements WPA3-SAE handshake capture using updated
aircrack-ng commands. Maintains backward compatibility
with WPA2.

Fixes #42

---

fix: Monitor mode detection on modern kernels

Updates interface detection to handle both mon0 and
wlan0mon naming conventions used by different kernel
versions and airmon-ng versions.

Fixes #56
```

## 🤝 Code Review Process

**What reviewers look for:**

1. **Functionality:** Does it work as intended?
2. **Compatibility:** Works on multiple distros?
3. **Security:** No vulnerabilities introduced?
4. **Code quality:** Follows style guide?
5. **Documentation:** Adequately documented?
6. **Testing:** Properly tested?

**Review response:**
- Address all comments
- Push additional commits to same PR
- Don't force-push unless requested
- Be respectful and open to feedback

## 🎓 Learning Resources

**Bash scripting:**
- [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)

**WiFi security:**
- [Aircrack-ng Documentation](https://aircrack-ng.org/documentation.html)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## 📧 Getting Help

- **Questions:** Use GitHub Discussions
- **Bugs:** Open an issue
- **Real-time chat:** Join our Discord (if available)

## 🏆 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Mentioned in release notes
- Added to AUTHORS file (if significant contribution)

## ⚖️ Legal Notice

By contributing, you agree that:
- Your contributions will be licensed under MIT License
- You have the right to submit the contribution
- Your code is for legitimate security testing purposes
- You understand the ethical and legal implications

---

Thank you for helping make AirHack-ng better! 🚀
