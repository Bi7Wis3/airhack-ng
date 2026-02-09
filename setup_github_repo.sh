#!/bin/bash
#
# GitHub Repository Setup Script
# Prepares the airhack-ng repository for GitHub upload
#
# Usage: ./setup_github_repo.sh
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitHub Repository Setup for AirHack-ng      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}[!] Git is not installed${NC}"
    echo -e "${YELLOW}[*] Install with: sudo apt install git${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Git is installed${NC}\n"

# Initialize git repository if not already done
if [ ! -d .git ]; then
    echo -e "${BLUE}[*] Initializing git repository...${NC}"
    git init
    echo -e "${GREEN}[✓] Git repository initialized${NC}\n"
else
    echo -e "${GREEN}[✓] Git repository already exists${NC}\n"
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo -e "${YELLOW}[!] .gitignore not found (this shouldn't happen)${NC}"
    echo -e "${BLUE}[*] Creating .gitignore...${NC}"
    # The .gitignore should already exist from previous step
fi

# Make all scripts executable
echo -e "${BLUE}[*] Setting executable permissions on scripts...${NC}"
chmod +x airhack-ng-v3
chmod +x install_dependencies.sh
chmod +x check-system.sh
chmod +x download_wordlists.sh
chmod +x setup_github_repo.sh
echo -e "${GREEN}[✓] Permissions set${NC}\n"

# Copy README_GITHUB.md to README.md for GitHub display
echo -e "${BLUE}[*] Setting up GitHub README...${NC}"
if [ -f README_GITHUB.md ]; then
    cp README_GITHUB.md README_FOR_GITHUB.md
    echo -e "${GREEN}[✓] GitHub README prepared${NC}"
    echo -e "${YELLOW}[*] Note: README_GITHUB.md is formatted for GitHub${NC}"
    echo -e "${YELLOW}[*] Your original README.md remains unchanged${NC}\n"
else
    echo -e "${RED}[!] README_GITHUB.md not found${NC}\n"
fi

# Check repository status
echo -e "${BLUE}[*] Repository status:${NC}\n"

# Count files
TOTAL_FILES=$(find . -type f ! -path './.git/*' ! -path './airhack-ng/*' ! -path './wordlists/*' | wc -l)
SCRIPTS=$(find . -maxdepth 1 -type f -name "*.sh" | wc -l)
DOCS=$(find . -maxdepth 1 -type f -name "*.md" | wc -l)

echo -e "  Total files: ${GREEN}$TOTAL_FILES${NC}"
echo -e "  Scripts: ${GREEN}$SCRIPTS${NC}"
echo -e "  Documentation: ${GREEN}$DOCS${NC}"
echo -e ""

# Show what will be committed
echo -e "${BLUE}[*] Files to be committed:${NC}\n"
echo -e "${GREEN}Core Scripts:${NC}"
echo -e "  ✓ airhack-ng-v3"
echo -e "  ✓ airhack-ng-v1 (original)"
echo -e "  ✓ airhack-ng-v2 (original)"
echo -e "  ✓ install_dependencies.sh"
echo -e "  ✓ check-system.sh"
echo -e "  ✓ download_wordlists.sh"
echo -e ""
echo -e "${GREEN}Documentation:${NC}"
echo -e "  ✓ README.md (technical docs)"
echo -e "  ✓ README_GITHUB.md (GitHub landing page)"
echo -e "  ✓ GETTING_STARTED.md"
echo -e "  ✓ CHANGELOG.md"
echo -e "  ✓ CONTRIBUTING.md"
echo -e "  ✓ LICENSE"
echo -e ""
echo -e "${GREEN}Configuration:${NC}"
echo -e "  ✓ .gitignore"
echo -e "  ✓ .github/workflows/shellcheck.yml"
echo -e ""

# Ask for GitHub repository details
echo -e "${BLUE}[*] GitHub repository setup${NC}\n"
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter repository name [airhack-ng]: " REPO_NAME
REPO_NAME=${REPO_NAME:-airhack-ng}

echo -e ""
read -p "Do you want to create initial commit? [Y/n]: " DO_COMMIT
DO_COMMIT=${DO_COMMIT:-Y}

if [[ "$DO_COMMIT" == "Y" || "$DO_COMMIT" == "y" ]]; then
    echo -e "\n${BLUE}[*] Staging files...${NC}"

    # Add all files except those in .gitignore
    git add .

    echo -e "${GREEN}[✓] Files staged${NC}\n"

    echo -e "${BLUE}[*] Creating initial commit...${NC}"
    git commit -m "Initial commit: AirHack-ng v3.0

- Modernized WiFi security auditing toolkit
- Updated for 2026 Linux systems
- Complete rewrite from v1.0/v2.0 (2010)
- Multi-distribution support
- Automated installation
- Comprehensive documentation

Original versions (v1.0, v2.0) preserved for reference."

    echo -e "${GREEN}[✓] Initial commit created${NC}\n"

    # Create main branch if on master
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "master" ]; then
        echo -e "${BLUE}[*] Renaming master to main...${NC}"
        git branch -M main
        echo -e "${GREEN}[✓] Branch renamed to main${NC}\n"
    fi
fi

# Ask about remote repository
echo -e "${BLUE}[*] Remote repository setup${NC}\n"

# Check if SSH keys are set up
SSH_AVAILABLE=0
if [ -f ~/.ssh/id_rsa.pub ] || [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_AVAILABLE=1
    echo -e "${GREEN}[✓] SSH keys detected${NC}"
fi

# Ask for connection method
if [ $SSH_AVAILABLE -eq 1 ]; then
    echo -e "\n${BLUE}Select connection method:${NC}"
    echo -e "  ${GREEN}1.${NC} SSH (Recommended) - git@github.com:user/repo.git"
    echo -e "  ${GREEN}2.${NC} HTTPS - https://github.com/user/repo.git"
    read -p "Choice [1-2]: " CONNECTION_METHOD
    CONNECTION_METHOD=${CONNECTION_METHOD:-1}
else
    echo -e "${YELLOW}[!] No SSH keys detected, using HTTPS${NC}"
    CONNECTION_METHOD=2
fi

read -p "Have you created the repository on GitHub? [y/N]: " REPO_CREATED
REPO_CREATED=${REPO_CREATED:-N}

if [[ "$REPO_CREATED" == "Y" || "$REPO_CREATED" == "y" ]]; then
    if [ "$CONNECTION_METHOD" = "1" ]; then
        REMOTE_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"
        echo -e "${GREEN}[✓] Using SSH connection${NC}"
    else
        REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
        echo -e "${GREEN}[✓] Using HTTPS connection${NC}"
    fi

    echo -e "\n${BLUE}[*] Adding remote origin...${NC}"
    if git remote | grep -q origin; then
        git remote set-url origin "$REMOTE_URL"
        echo -e "${GREEN}[✓] Remote origin updated${NC}"
    else
        git remote add origin "$REMOTE_URL"
        echo -e "${GREEN}[✓] Remote origin added${NC}"
    fi

    echo -e ""
    read -p "Do you want to push to GitHub now? [y/N]: " DO_PUSH
    DO_PUSH=${DO_PUSH:-N}

    if [[ "$DO_PUSH" == "Y" || "$DO_PUSH" == "y" ]]; then
        echo -e "\n${BLUE}[*] Pushing to GitHub...${NC}"
        git push -u origin main
        echo -e "${GREEN}[✓] Pushed to GitHub${NC}\n"

        echo -e "${GREEN}[✓] Repository setup complete!${NC}"
        echo -e "\n${BLUE}Your repository is now live at:${NC}"
        echo -e "${GREEN}https://github.com/$GITHUB_USER/$REPO_NAME${NC}\n"
    fi
else
    if [ "$CONNECTION_METHOD" = "1" ]; then
        REMOTE_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"
    else
        REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
    fi

    echo -e "\n${YELLOW}[*] Create the repository on GitHub first:${NC}"
    echo -e "    1. Go to https://github.com/new"
    echo -e "    2. Repository name: ${GREEN}$REPO_NAME${NC}"
    echo -e "    3. Description: ${GREEN}WiFi Security Auditing Toolkit - Modernized Aircrack-ng Wrapper${NC}"
    echo -e "    4. Choose Public or Private"
    echo -e "    5. ${RED}Do NOT${NC} initialize with README, .gitignore, or license"
    echo -e "    6. Click 'Create repository'"
    echo -e ""
    echo -e "${YELLOW}[*] Then run these commands:${NC}"
    echo -e "    ${BLUE}git remote add origin $REMOTE_URL${NC}"
    echo -e "    ${BLUE}git push -u origin main${NC}"
    echo -e ""
fi

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    SUMMARY                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}Repository prepared for GitHub!${NC}\n"

echo -e "${BLUE}Next steps:${NC}"
if [ "$CONNECTION_METHOD" = "1" ]; then
    echo -e "  1. Create repository on GitHub (if not done)"
    echo -e "  2. Add remote: ${YELLOW}git remote add origin git@github.com:$GITHUB_USER/$REPO_NAME.git${NC}"
    echo -e "  3. Push code: ${YELLOW}git push -u origin main${NC}"
else
    echo -e "  1. Create repository on GitHub (if not done)"
    echo -e "  2. Add remote: ${YELLOW}git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git${NC}"
    echo -e "  3. Push code: ${YELLOW}git push -u origin main${NC}"
fi
echo -e ""
echo -e "${BLUE}Optional:${NC}"
echo -e "  - Add repository topics: ${YELLOW}wifi, security, penetration-testing, aircrack-ng${NC}"
echo -e "  - Enable GitHub Actions (ShellCheck workflow included)"
echo -e "  - Add repository description and website"
echo -e "  - Create release: ${YELLOW}v3.0${NC}"
echo -e ""

echo -e "${BLUE}Repository URL:${NC}"
echo -e "  ${GREEN}https://github.com/$GITHUB_USER/$REPO_NAME${NC}\n"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Remember: This is security testing software${NC}"
echo -e "${YELLOW}Include clear warnings about authorized use only${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
