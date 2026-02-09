#!/bin/bash
#
# Quick Push to GitHub Script
# Automates git add, commit, and push workflow
#
# Usage: ./push_to_github.sh [optional commit message]
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Quick Push to GitHub Script           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}\n"

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}[!] Not a git repository${NC}"
    echo -e "${YELLOW}[*] Run this script from the repository root${NC}"
    exit 1
fi

# Check git status
echo -e "${BLUE}[*] Checking git status...${NC}\n"
git status

# Check if there are changes
if git diff-index --quiet HEAD --; then
    echo -e "\n${GREEN}[✓] Working tree clean - nothing to commit${NC}"
    exit 0
fi

# Show what will be committed
echo -e "\n${BLUE}[*] Files to be committed:${NC}"
git status --short

# Ask for confirmation
echo -e ""
read -p "Add all changes and commit? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-Y}

if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    echo -e "${YELLOW}[*] Aborted${NC}"
    exit 0
fi

# Stage all changes
echo -e "\n${BLUE}[*] Staging all changes...${NC}"
git add -A

# Get commit message
if [ -n "$1" ]; then
    # Use provided commit message
    COMMIT_MSG="$*"
else
    # Ask for commit message
    echo -e "\n${YELLOW}[*] Enter commit message:${NC}"
    read -p "> " COMMIT_MSG

    if [ -z "$COMMIT_MSG" ]; then
        echo -e "${RED}[!] Commit message required${NC}"
        exit 1
    fi
fi

# Add co-author tag
COMMIT_MSG="${COMMIT_MSG}

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Commit
echo -e "\n${BLUE}[*] Creating commit...${NC}"
git commit -m "$COMMIT_MSG"

if [ $? -ne 0 ]; then
    echo -e "${RED}[!] Commit failed${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Commit created${NC}"

# Push to GitHub
echo -e "\n${BLUE}[*] Pushing to GitHub...${NC}"
read -p "Push to origin main? [Y/n]: " PUSH_CONFIRM
PUSH_CONFIRM=${PUSH_CONFIRM:-Y}

if [[ "$PUSH_CONFIRM" == "Y" || "$PUSH_CONFIRM" == "y" ]]; then
    git push origin main

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              PUSH SUCCESSFUL! ✓                ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"

        # Show repository URL
        REPO_URL=$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        echo -e "${BLUE}Repository:${NC} $REPO_URL"
        echo -e "${GREEN}[✓] Changes are now live on GitHub!${NC}\n"
    else
        echo -e "${RED}[!] Push failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[*] Skipped push (commit saved locally)${NC}"
    echo -e "${BLUE}[*] To push later, run: git push origin main${NC}"
fi
