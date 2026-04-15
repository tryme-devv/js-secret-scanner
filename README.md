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

