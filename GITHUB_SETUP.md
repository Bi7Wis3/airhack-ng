# GitHub Setup Guide with SSH

Quick reference for uploading AirHack-ng to GitHub using SSH keys.

## ✅ You Have SSH Keys Set Up!

Since you've already configured SSH keys, you can use the faster and more secure SSH connection method.

## 🚀 Quick Upload (5 Minutes)

### Step 1: Run Setup Script

```bash
cd /home/bitwise/bin/AI_AirCrack
./setup_github_repo.sh
```

**When prompted:**
- Select **option 1 (SSH)** when asked for connection method
- Enter your GitHub username
- Enter repository name (e.g., `airhack-ng`)
- Answer `Y` to create initial commit

### Step 2: Create Repository on GitHub

**Go to:** https://github.com/new

**Settings:**
- **Repository name:** `airhack-ng`
- **Description:** `WiFi Security Auditing Toolkit - Modern Aircrack-ng Wrapper`
- **Public** (recommended for open-source tools)
- **❌ Do NOT check any boxes** (README, .gitignore, license already included)

**Click:** "Create repository"

### Step 3: Push to GitHub

The setup script will offer to push automatically, or you can run:

```bash
git remote add origin git@github.com:YOUR_USERNAME/airhack-ng.git
git push -u origin main
```

## 🔑 SSH vs HTTPS

**SSH (Recommended - You're using this!):**
```bash
git@github.com:username/repo.git
```
✅ No password prompts
✅ More secure
✅ Faster authentication
✅ Works with 2FA easily

**HTTPS (Alternative):**
```bash
https://github.com/username/repo.git
```
❌ Requires personal access token
❌ Password prompts (deprecated)
⚠️ More steps with 2FA

## 🧪 Test Your SSH Connection

Before uploading, verify your SSH key works:

```bash
ssh -T git@github.com
```

**Expected output:**
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see this, you're ready to push! ✅

**If it fails:**
```bash
# Check your SSH keys
ls -la ~/.ssh

# Should see:
# id_rsa and id_rsa.pub (RSA key)
# OR
# id_ed25519 and id_ed25519.pub (Ed25519 key)

# Make sure key is added to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519  # or id_rsa
```

## 📋 Complete Workflow

### 1. Initialize Repository

```bash
cd /home/bitwise/bin/AI_AirCrack

# Run automated setup
./setup_github_repo.sh
```

### 2. Create on GitHub

- Go to https://github.com/new
- Create repository (don't initialize)

### 3. Connect and Push

```bash
# Add remote (SSH)
git remote add origin git@github.com:USERNAME/airhack-ng.git

# Verify remote
git remote -v

# Push to GitHub
git push -u origin main
```

### 4. Verify Upload

Visit: `https://github.com/USERNAME/airhack-ng`

You should see:
- ✅ All scripts and documentation
- ✅ README rendered nicely
- ✅ License file
- ✅ .github/workflows for CI/CD

## 🎨 Post-Upload Setup

### Add Repository Topics

**Go to:** Repository Settings → Topics

**Add:**
- `wifi`
- `security`
- `penetration-testing`
- `aircrack-ng`
- `wireless`
- `ethical-hacking`
- `security-tools`
- `bash`

### Enable GitHub Actions

**Go to:** Actions tab → Enable workflows

The ShellCheck workflow will:
- Run on every push/PR
- Check bash syntax
- Report code quality issues

### Create First Release

**Go to:** Releases → Create a new release

**Tag:** `v3.0`
**Title:** `AirHack-ng v3.0 - Complete Modernization`
**Description:** (Copy from CHANGELOG.md)

### Update Repository Settings

**Go to:** Settings

**General:**
- Description: `WiFi security auditing toolkit - Modern wrapper for Aircrack-ng`
- Website: `https://aircrack-ng.org`
- Topics: (as above)

**Features:**
- ✅ Issues
- ✅ Discussions (optional)
- ❌ Wiki (not needed)
- ❌ Projects (not needed)

## 🔄 Future Updates

### Making Changes

```bash
# Make your changes to files
nano airhack-ng-v3

# Stage changes
git add .

# Commit
git commit -m "feat: Add new feature description"

# Push
git push origin main
```

### Pulling Updates

```bash
# Get latest from GitHub
git pull origin main
```

## 🌟 Recommended Repository Structure

Your repository is already set up with:

```
airhack-ng/
├── .github/
│   └── workflows/
│       └── shellcheck.yml       ✅ CI/CD ready
├── .gitignore                   ✅ Excludes large files
├── LICENSE                      ✅ MIT License
├── README_GITHUB.md            ✅ GitHub landing page
├── GETTING_STARTED.md          ✅ Tutorial
├── CHANGELOG.md                ✅ Version history
├── CONTRIBUTING.md             ✅ Contribution guide
├── airhack-ng-v3               ✅ Main tool
├── install_dependencies.sh     ✅ Installer
├── download_wordlists.sh       ✅ Wordlist getter
└── check-system.sh             ✅ System checker
```

## 🐛 Troubleshooting

### "Permission denied (publickey)"

**Problem:** SSH key not recognized

**Solution:**
```bash
# Check SSH key is added
ssh-add -l

# If empty, add key
ssh-add ~/.ssh/id_ed25519  # or id_rsa

# Verify GitHub connection
ssh -T git@github.com
```

### "Remote origin already exists"

**Problem:** Remote already configured

**Solution:**
```bash
# View current remote
git remote -v

# Update remote URL
git remote set-url origin git@github.com:USERNAME/airhack-ng.git

# Or remove and re-add
git remote remove origin
git remote add origin git@github.com:USERNAME/airhack-ng.git
```

### "Failed to push refs"

**Problem:** Remote has changes you don't have locally

**Solution:**
```bash
# Pull first (if you initialized with README on GitHub)
git pull origin main --allow-unrelated-histories

# Then push
git push -u origin main
```

### "Repository not found"

**Problem:** Wrong repository name or permissions

**Solution:**
```bash
# Verify repository exists
# Check repository name matches exactly
# Ensure you have push access

# Check remote URL
git remote -v

# Update if wrong
git remote set-url origin git@github.com:USERNAME/correct-name.git
```

## 📱 GitHub Mobile App

You can also manage your repository from your phone:
- View code
- Review issues
- Merge pull requests
- Check Actions status

**Download:** GitHub Mobile (iOS/Android)

## 🎓 SSH Key Management

### View your SSH keys

```bash
cat ~/.ssh/id_ed25519.pub
# or
cat ~/.ssh/id_rsa.pub
```

### Add to GitHub (if not already done)

1. Copy key: `cat ~/.ssh/id_ed25519.pub`
2. Go to: https://github.com/settings/keys
3. Click "New SSH key"
4. Paste and save

### Generate new key (if needed)

```bash
# Ed25519 (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"

# RSA (legacy)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## ✨ You're Ready!

Everything is configured for SSH. Just run:

```bash
./setup_github_repo.sh
```

And follow the prompts! Your repository will be live in minutes. 🚀

## 📚 Additional Resources

- [GitHub SSH Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
