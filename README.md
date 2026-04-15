# 🔍 JS Secret Scanner

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/tryme-devv/js-secret-scanner)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/shell-bash4.0+-orange.svg)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![GitHub stars](https://img.shields.io/github/stars/tryme-devv/js-secret-scanner)](https://github.com/tryme-devv/js-secret-scanner/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/tryme-devv/js-secret-scanner)](https://github.com/tryme-devv/js-secret-scanner/network)

**Automated JavaScript Secret Discovery Tool** - Find hardcoded API keys, tokens, credentials, and sensitive data in JavaScript files.

> ⚠️ **For authorized security testing only!** Use only on domains you own or have explicit permission to test.

---

## 📋 Table of Contents

- [Features](#-features)
- [Demo](#-demo)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage Guide](#-usage-guide)
- [Secret Patterns](#-secret-patterns-detected)
- [Output Structure](#-output-structure)
- [Real-World Example](#-real-world-example)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Disclaimer](#-disclaimer)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔍 **Multi-Source Discovery** | Finds JS files using Wayback Machine, GAU, and custom crawlers |
| 🚀 **Fast Scanning** | Parallel downloading with automatic rate limiting |
| 📊 **30+ Secret Patterns** | Detects API keys, tokens, passwords, database URLs, and more |
| 🎨 **Color Output** | Easy-to-read terminal interface with color coding |
| 💾 **Offline Analysis** | Downloads all JS files for deep inspection |
| 📝 **Detailed Reports** | Context-aware results with line numbers and file paths |
| 🔄 **Auto-Install** | Automatically installs required tools (waybackurls, gau) |
| 📂 **Organized Output** | Structured directory with separate folders for downloads and secrets |

---

## 🎥 Demo

```bash
$ ./js-secret-scanner.sh example.com

╔═══════════════════════════════════════════════════════════╗
║     JS Secret Hunter - Automated Secret Discovery        ║
╚═══════════════════════════════════════════════════════════╝

[+] Target: example.com
[+] Output: js_secrets_example.com_20260415_143022

[*] Checking tools...
[+] Tools ready

[*] Discovering JS files...
[+] Found 47 JS files

[*] Scanning JS files...
[47/47] Scanning... Complete!

[*] Generating report...

JS SECRET SCANNER REPORT
========================
Domain: example.com
Date: Wed Apr 15 14:30:22 UTC 2026

STATISTICS:
- JS Files Found: 47
- Files Downloaded: 47
- Secrets Found: 2

SECRETS FOUND:
==============
./downloads/example_com_app.js:306: token: 'lLt6uiNPcRk.Dlwc3b4Hehu...'
./downloads/example_com_config.js:45: apiKey: 'AIzaSyCk-6kqU_1vK8xYz...'

✅ Scan Complete!

 Installation
One-Line Installation
bash
git clone https://github.com/tryme-devv/js-secret-scanner.git
cd js-secret-scanner
chmod +x js-secret-scanner.sh setup.sh
./setup.sh
Manual Installation
bash
# Clone the repository
git clone https://github.com/tryme-devv/js-secret-scanner.git
cd js-secret-scanner

# Make scripts executable
chmod +x js-secret-scanner.sh

# Install dependencies manually
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest

# Add Go binaries to PATH
export PATH=$PATH:$(go env GOPATH)/bin
Docker Installation (Coming Soon)
bash
# Future feature
docker pull tryme-devv/js-secret-scanner
docker run tryme-devv/js-secret-scanner example.com
Requirements
Bash 4.0+ (run bash --version to check)

Go 1.16+ (for tool installation)

curl, grep, sed (standard Linux tools)

Internet connection (for API calls)

🚀 Quick Start
Basic Usage
bash
# Scan a single domain
./js-secret-scanner.sh example.com

# Scan with custom output directory
./js-secret-scanner.sh example.com -o my_scan_results

# Quick scan (skip external tools)
./js-secret-scanner.sh example.com --quick
Advanced Usage
bash
# Scan multiple domains from a file
cat domains.txt | while read domain; do
    ./js-secret-scanner.sh "$domain"
done

# Scan and only show critical findings
./js-secret-scanner.sh example.com | grep -E "(CRITICAL|HIGH)"

# Save output to file
./js-secret-scanner.sh example.com 2>&1 | tee scan.log

# Background scan with nohup
nohup ./js-secret-scanner.sh example.com &
Batch Scanning
bash
# Create a domains file
echo "example.com" > domains.txt
echo "test.com" >> domains.txt
echo "demo.com" >> domains.txt

# Scan all domains
while read domain; do
    echo "Scanning: $domain"
    ./js-secret-scanner.sh "$domain"
    sleep 5  # Rate limiting
done < domains.txt
🎯 Secret Patterns Detected
The scanner detects 30+ secret patterns across multiple categories:

API Keys & Tokens
regex
api[_-]?key|apikey|api_key
access[_-]?token|auth_token|bearer
secret|secretkey|secret_key
jwt[_-]?secret|jsonwebtoken
Cloud Services
regex
aws[_-]?key|s3[_-]?key|aws_secret
firebase|google_api|google_cloud
azure|azure_key|azure_secret
Authentication
regex
password|passwd|pwd|credential
private[_-]?key|rsa[_-]?key|ssh[_-]?key
client[_-]?id|client[_-]?secret
Databases
regex
mongodb|mysql|postgresql|redis
database[_-]?url|db_connection
Webhooks & Integrations
regex
slack[_-]?token|discord[_-]?token
webhook[_-]?url|callback[_-]?url
stripe[_-]?(key|secret)|paypal[_-]?key
github[_-]?token|gitlab[_-]?token
Generic Secrets
regex
['"`][A-Za-z0-9+/]{40,}['"`]  # Base64-like strings
['"`][0-9a-f]{32,}['"`]       # MD5/SHA-like hashes
['"`][A-Z0-9]{20,}['"`]       # Uppercase alphanumeric
📁 Output Structure
After running the scanner, you'll get this directory structure:

text
js_secrets_example.com_20260415_143022/
│
├── js_urls.txt                 # All discovered JavaScript URLs
├── secrets.txt                 # Raw secret matches (grep output)
├── REPORT.txt                  # Complete analysis report
│
├── downloads/                  # Downloaded JS files
│   ├── example_com_app.js
│   ├── example_com_main.js
│   ├── example_com_vendor_js
│   └── ...
│
└── (future) secrets/           # Organized secret findings
    ├── api_keys.txt
    ├── tokens.txt
    ├── passwords.txt
    └── with_context.txt
Sample Report
bash
$ cat js_secrets_example.com_*/REPORT.txt

JS SECRET SCANNER REPORT
========================
Domain: example.com
Date: Wed Apr 15 14:30:22 UTC 2026

STATISTICS:
- JS Files Found: 47
- Files Downloaded: 47
- Secrets Found: 2

SECRETS FOUND:
==============
./downloads/example_com_app.js:306: token: 'lLt6uiNPcRk.Dlwc3b4Hehu...'
./downloads/example_com_config.js:45: apiKey: 'AIzaSyCk-6kqU_1vK8xYz...'

OUTPUT FILES:
- JS URLs: js_secrets_example.com_20260415_143022/js_urls.txt
- Downloads: js_secrets_example.com_20260415_143022/downloads/
- Secrets: js_secrets_example.com_20260415_143022/secrets.txt
🔬 Real-World Example
Finding a Hardcoded Token
Here's what happened when scanning xcmstdc.tata.com:

bash
$ ./js-secret-scanner.sh xcmstdc.tata.com

[+] Found 127 JS files
[+] Scanning complete!

SECRETS FOUND:
==============
chatbot.min.js:306: token: 'lLt6uiNPcRk.Dlwc3b4Hehu_Qg9ks4B_MvYsum9QSEvk8Wrd8gGtz7M'
The exposed token was valid and could:

✅ Authenticate with Microsoft Direct Line API

✅ Create unlimited chatbot conversations

✅ Generate fresh tokens

✅ Access real-time chat streams

This finding was reported responsibly and confirmed as a CRITICAL vulnerability.

🛠️ Troubleshooting
Common Issues & Solutions
Issue	Solution
waybackurls: command not found	Run export PATH=$PATH:$(go env GOPATH)/bin
No JS files found	Domain may not be archived; try manual enumeration
Connection timeout	Increase timeout or check internet connection
Permission denied	Run chmod +x js-secret-scanner.sh
Go not installed	Install Go: https://golang.org/dl/
Debug Mode
bash
# Run with bash debug
bash -x js-secret-scanner.sh example.com

# Check if tools are installed
which waybackurls gau
Manual Fallback
If automated discovery fails:

bash
# Manual URL discovery
echo "example.com" | waybackurls | grep "\.js$" > manual_js.txt

# Manual scanning
while read url; do
    curl -s "$url" | grep -i "token\|secret\|key"
done < manual_js.txt
🤝 Contributing
Contributions are welcome! Here's how you can help:

Ways to Contribute
🐛 Report bugs - Open an issue

💡 Suggest features - Open an issue with enhancement label

📝 Improve documentation - Fix typos, add examples

🔧 Submit PRs - Fix bugs or add features

⭐ Star the repo - Show your support

Development Setup
bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/js-secret-scanner.git
cd js-secret-scanner

# Create feature branch
git checkout -b feature/amazing-feature

# Make changes and test
./js-secret-scanner.sh testdomain.com

# Commit and push
git commit -m "Add amazing feature"
git push origin feature/amazing-feature

# Open Pull Request
Coding Standards
Use meaningful variable names

Add comments for complex logic

Test with multiple domains

Update documentation for new features

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

text
MIT License

Copyright (c) 2026 tryme-devv

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
⚠️ Disclaimer
IMPORTANT: USE RESPONSIBLY

This tool is for educational and authorized testing purposes only.

By using this software, you agree to:

✅ Only scan domains you own or have explicit permission to test

✅ Follow responsible disclosure practices if you find vulnerabilities

✅ Not use found credentials for unauthorized access

✅ Comply with all applicable laws and regulations

The author assumes no liability for misuse of this tool.

Responsible Disclosure
If you discover real vulnerabilities:

Stop testing immediately

Document your findings (screenshots, steps)

Report to the vendor through official channels

Do not disclose publicly until fixed

Wait for acknowledgment before sharing

📞 Support & Contact
GitHub Issues: https://github.com/tryme-devv/js-secret-scanner/issues

Security Issues: Please report responsibly via GitHub Issues (private)

Discussions: GitHub Discussions

Author: tryme-devv

🌟 Star History
https://api.star-history.com/svg?repos=tryme-devv/js-secret-scanner&type=Date

🙏 Acknowledgments
TomNomNom for waybackurls

lc for gau (GetAllUrls)

The entire bug bounty community for inspiration

📊 Project Status
✅ Stable - Core functionality working

🔄 Active Development - New features coming

📝 Documentation - Continuously improving

🐛 Bug Fixes - Regular updates

Roadmap
Parallel downloading for faster scans

JSON/CSV output formats

Docker container support

GitHub Actions integration

Web interface (optional)

More secret patterns

Machine learning detection

🎯 Quick Commands Reference
bash
# Installation
git clone https://github.com/tryme-devv/js-secret-scanner.git
cd js-secret-scanner && ./setup.sh

# Basic scan
./js-secret-scanner.sh example.com

# Batch scan
cat domains.txt | xargs -I {} ./js-secret-scanner.sh {}

# Check results
cat js_secrets_*/REPORT.txt
grep -r "CRITICAL" js_secrets_*/

# Clean up
rm -rf js_secrets_*/
Made with ❤️ by tryme-devv for the security research community

https://img.shields.io/github/followers/tryme-devv?label=Follow&style=social
https://img.shields.io/twitter/url?style=social&url=https%253A%252F%252Fgithub.com%252Ftryme-devv%252Fjs-secret-scanner

⭐ Star this repo if you find it useful!

text

---

## 🚀 **How to Add This README to Your Repository**

### Method 1: Direct Copy (Recommended)

```bash
# Navigate to your project
cd ~/js-secret-scanner

# Open README for editing
nano README.md

# Copy the ENTIRE README from above
# Paste it (right-click or Ctrl+Shift+V)
# Save and exit (Ctrl+X, then Y, then Enter)

# Verify it looks good
cat README.md | head -20

# Commit and push
git add README.md
git commit -m "Add professional README with documentation"
git push origin main
Method 2: Download Directly
bash
# If you have wget
cd ~/js-secret-scanner
wget -O README.md https://raw.githubusercontent.com/tryme-devv/js-secret-scanner/main/README.md

# Or create it manually with cat
cat > README.md << 'EOF'
[PASTE THE ENTIRE README HERE]
EOF
✅ Final Checklist
README.md is saved in your project root

File starts with # 🔍 JS Secret Scanner

All badges point to your GitHub (tryme-devv)

No placeholder text remains

Pushed to GitHub successfully

View on GitHub to verify formatting

🎨 Bonus: Add Badges to README
The README already includes these badges - they'll automatically work once pushed:

Version badge

License badge

Stars badge

Forks badge

PRs welcome badge

📱 View Your README Online
Once pushed, go to:

text
https://github.com/tryme-devv/js-secret-scanner
GitHub will automatically render the README with all formatting, colors, and badges!

Your README is now production-ready! 🎉 Want me to help you add screenshots, a demo GIF, or create a wiki for your repository?



