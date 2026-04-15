# Create project directory
cd ~
mkdir js-secret-scannerr
cd js-secret-scannerr

# Create the enhanced main script
cat > js-secret-scanner.sh << 'EOF'
#!/bin/bash

# Enhanced JS Secret Scanner - Professional Edition
# Version: 2.0

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
THREADS=10
TIMEOUT=15
MAX_FILE_SIZE=5242880  # 5MB
USER_AGENT="Mozilla/5.0 (JS-Secret-Scanner/2.0)"

# Banner
banner() {
    echo -e "${CYAN}"
    cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║     ██╗███████╗    ███████╗███████╗██╗   ██╗██████╗          ║
║     ██║██╔════╝    ██╔════╝██╔════╝██║   ██║██╔══██╗         ║
║     ██║███████╗    ███████╗█████╗  ██║   ██║██████╔╝         ║
║██   ██║╚════██║    ╚════██║██╔══╝  ██║   ██║██╔══██╗         ║
║╚█████╔╝███████║    ███████║███████╗╚██████╔╝██║  ██║         ║
║ ╚════╝ ╚══════╝    ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝         ║
║                                                              ║
║           JS SECRET HUNTER - PROFESSIONAL EDITION           ║
║              Automated Secret Discovery Tool                ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

# Help menu
show_help() {
    cat << EOF
${GREEN}USAGE:${NC}
    $0 [OPTIONS] <domain>

${GREEN}OPTIONS:${NC}
    -h, --help              Show this help message
    -t, --threads NUM       Number of concurrent threads (default: 10)
    -o, --output DIR        Custom output directory
    -d, --depth NUM         Crawl depth for JS discovery (default: 2)
    -f, --file FILE         Read domains from file
    --no-wayback            Skip Wayback Machine discovery
    --no-crawl              Skip crawling for JS files
    --no-download           Skip downloading JS files
    --regex FILE            Use custom regex patterns file
    --quiet                 Suppress verbose output
    --json                  Generate JSON output

${GREEN}EXAMPLES:${NC}
    $0 example.com
    $0 -t 20 -d 3 example.com
    $0 -f domains.txt --json
    $0 --no-wayback example.com

EOF
    exit 0
}

# Logging functions
log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[-]${NC} $1" >&2; }
log_debug() { [ "$QUIET" != true ] && echo -e "${MAGENTA}[D]${NC} $1"; }

# Check and install tools
check_tools() {
    log_info "Checking required tools..."
    
    local missing_tools=()
    
    # Check Go
    if ! command -v go &> /dev/null; then
        missing_tools+=("go")
    fi
    
    # Check/Install waybackurls
    if ! command -v waybackurls &> /dev/null && [ "$NO_WAYBACK" != true ]; then
        log_warning "waybackurls not found. Installing..."
        go install github.com/tomnomnom/waybackurls@latest 2>/dev/null || {
            log_error "Failed to install waybackurls"
            NO_WAYBACK=true
        }
    fi
    
    # Check/Install httpx
    if ! command -v httpx &> /dev/null; then
        log_warning "httpx not found. Installing for better JS discovery..."
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null
    fi
    
    # Check/Install gau
    if ! command -v gau &> /dev/null && [ "$NO_WAYBACK" != true ]; then
        log_warning "gau not found. Installing for additional URLs..."
        go install github.com/lc/gau/v2/cmd/gau@latest 2>/dev/null
    fi
    
    # Add Go binaries to PATH
    export PATH=$PATH:$(go env GOPATH)/bin
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install: brew install ${missing_tools[*]} (macOS) or apt-get install ${missing_tools[*]} (Linux)"
        exit 1
    fi
    
    log_success "Tools ready"
}

# Advanced JS discovery
discover_js() {
    log_info "Discovering JavaScript files..."
    
    local js_files=()
    
    # Method 1: Wayback Machine
    if [ "$NO_WAYBACK" != true ]; then
        log_debug "Fetching from Wayback Machine..."
        if command -v waybackurls &> /dev/null; then
            echo "$DOMAIN" | waybackurls 2>/dev/null | grep -E "\.js($|\?)|\.jsx|\.mjs" >> "$JS_URLS_TEMP"
        fi
        if command -v gau &> /dev/null; then
            gau --subs "$DOMAIN" 2>/dev/null | grep -E "\.js($|\?)|\.jsx|\.mjs" >> "$JS_URLS_TEMP"
        fi
    fi
    
    # Method 2: Crawling
    if [ "$NO_CRAWL" != true ]; then
        log_debug "Crawling target for JS files..."
        
        # Use curl for basic crawling
        if command -v httpx &> /dev/null; then
            echo "https://$DOMAIN" | httpx -silent -threads $THREADS -follow-redirects -crawl -depth $DEPTH 2>/dev/null | grep -E "\.js($|\?)|\.jsx" >> "$JS_URLS_TEMP"
        else
            # Basic crawling fallback
            curl -sL "https://$DOMAIN" -A "$USER_AGENT" --max-time $TIMEOUT | grep -oP '(?:src|href)=["'\''][^"'\'']*\.js[^"'\'']*["'\'']' | cut -d'"' -f2 | sed "s|^/|https://$DOMAIN/|" >> "$JS_URLS_TEMP" 2>/dev/null
        fi
    fi
    
    # Method 3: Common CDN patterns
    cat >> "$JS_URLS_TEMP" << EOF
https://cdn.jsdelivr.net/npm/*.js
https://unpkg.com/*.js
https://ajax.googleapis.com/ajax/libs/*/jquery*.js
EOF
    
    # Process and deduplicate URLs
    sort -u "$JS_URLS_TEMP" | grep -E "^https?://" | while read -r url; do
        # Validate URL
        if [[ "$url" =~ ^https?:// ]]; then
            echo "$url" >> "$JS_URLS_FILE"
        fi
    done
    
    # Filter valid URLs
    sed -i 's/\?.*$//' "$JS_URLS_FILE" 2>/dev/null || true
    sort -u -o "$JS_URLS_FILE" "$JS_URLS_FILE"
    
    local count=$(wc -l < "$JS_URLS_FILE" 2>/dev/null || echo "0")
    log_success "Found $count unique JS files"
    
    if [ "$count" -eq 0 ]; then
        log_error "No JS files found. Try: --no-wayback or check domain"
        exit 1
    fi
}

# Enhanced secret patterns
get_secret_patterns() {
    cat << 'PATTERNS'
# API Keys & Tokens
(api[_-]?key|apikey|api_key)[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9_\-]{16,64})["'"'"']
(access[_-]?token|auth_token|bearer)[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9_\-\.]{20,})["'"'"']
(secret|secretkey|secret_key)[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9_\-]{16,})["'"'"']

# Cloud Services
aws[_-]?(access|secret)?[_-]?key[[:space:]]*[:=][[:space:]]*["'"'"'](AKIA[0-9A-Z]{16})["'"'"']
s3[_-]?key[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9/+=]{40})["'"'"']
google_api[_-]?key[[:space:]]*[:=][[:space:]]*["'"'"'](AIza[0-9A-Za-z\-_]{35})["'"'"']
firebase[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9\-]{20,})["'"'"']

# Social & Communication
github[_-]?token[[:space:]]*[:=][[:space:]]*["'"'"'](ghp_[0-9A-Za-z]{36})["'"'"']
slack[_-]?token[[:space:]]*[:=][[:space:]]*["'"'"'](xox[baprs]-[0-9A-Za-z\-]{10,})["'"'"']
discord[_-]?token[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9_\-]{24,})["'"'"']

# Database
mongodb[[:space:]]*[:=][[:space:]]*["'"'"'](mongodb://[^"'"'"']+)["'"'"']
postgresql[[:space:]]*[:=][[:space:]]*["'"'"'](postgresql://[^"'"'"']+)["'"'"']
redis[[:space:]]*[:=][[:space:]]*["'"'"'](redis://[^"'"'"']+)["'"'"']

# JWT & Encryption
jwt[_-]?secret[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9_\-\.]{32,})["'"'"']
private[_-]?key[[:space:]]*[:=][[:space:]]*["'"'"'](-----BEGIN [A-Z]+ PRIVATE KEY-----)["'"'"']

# Payment
stripe[_-]?(key|secret)[[:space:]]*[:=][[:space:]]*["'"'"'](sk_live_[0-9a-zA-Z]{24})["'"'"']
paypal[_-]?(key|secret)[[:space:]]*[:=][[:space:]]*["'"'"']([a-zA-Z0-9]{32,})["'"'"']

# Generic passwords
(password|passwd|pwd)[[:space:]]*[:=][[:space:]]*["'"'"']([^"'"'"' ]{8,})["'"'"']
PATTERNS
}

# Download and scan with concurrency
download_and_scan() {
    log_info "Scanning JS files (using $THREADS threads)..."
    
    mkdir -p "$OUTPUT_DIR/downloads"
    > "$SECRETS_FILE"
    > "$OUTPUT_DIR/urls_scanned.txt"
    
    local total=$(wc -l < "$JS_URLS_FILE")
    local scanned=0
    local found=0
    
    # Create temp directory for parallel processing
    local temp_dir=$(mktemp -d)
    
    # Export variables for parallel processes
    export -f scan_single_file
    export OUTPUT_DIR SECRETS_FILE USER_AGENT TIMEOUT MAX_FILE_SIZE
    
    # Process files in parallel
    cat "$JS_URLS_FILE" | xargs -P $THREADS -I {} bash -c 'scan_single_file "$@"' _ {} &
    local pid=$!
    
    # Show progress spinner
    while kill -0 $pid 2>/dev/null; do
        scanned=$(wc -l < "$OUTPUT_DIR/urls_scanned.txt" 2>/dev/null || echo 0)
        found=$(grep -c "found in:" "$SECRETS_FILE" 2>/dev/null || echo 0)
        echo -ne "${CYAN}[$scanned/$total] Scanned | ${GREEN}Found: $found${NC}   \r"
        sleep 0.5
    done
    
    wait $pid
    echo "" # New line after progress
    
    log_success "Scan complete. Found $found potential secrets"
}

# Function to scan single file (used by xargs)
scan_single_file() {
    local url="$1"
    local scanned_file="$OUTPUT_DIR/urls_scanned.txt"
    
    echo "$url" >> "$scanned_file"
    
    local filename=$(echo "$url" | md5sum | cut -c1-10)
    local filepath="$OUTPUT_DIR/downloads/$filename.js"
    
    # Download file with timeout and size limit
    curl -s -L --max-time $TIMEOUT -H "User-Agent: $USER_AGENT" \
         --max-filesize $MAX_FILE_SIZE -o "$filepath" "$url" 2>/dev/null
    
    if [ -s "$filepath" ]; then
        # Get secret patterns
        local patterns=$(get_secret_patterns)
        
        # Scan for secrets
        while IFS= read -r pattern; do
            [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
            grep -H -i -n -E "$pattern" "$filepath" 2>/dev/null | while read -r line; do
                echo "found in: $url" >> "$SECRETS_FILE"
                echo "$line" >> "$SECRETS_FILE"
                echo "---" >> "$SECRETS_FILE"
            done
        done <<< "$patterns"
        
        # Check for base64 encoded secrets
        grep -E '[A-Za-z0-9+/]{40,}={0,2}' "$filepath" | while read -r line; do
            echo "possible base64 encoded secret in: $url" >> "$SECRETS_FILE"
            echo "$line" >> "$SECRETS_FILE"
            echo "---" >> "$SECRETS_FILE"
        done
    fi
}

# Generate comprehensive report
generate_report() {
    log_info "Generating report..."
    
    local js_count=$(wc -l < "$JS_URLS_FILE")
    local scanned_count=$(wc -l < "$OUTPUT_DIR/urls_scanned.txt" 2>/dev/null || echo 0)
    local secrets_count=$(grep -c "found in:" "$SECRETS_FILE" 2>/dev/null || echo 0)
    
    # Text report
    cat > "$REPORT_FILE" << EOF
╔══════════════════════════════════════════════════════════════╗
║              JS SECRET SCANNER - SCAN REPORT                 ║
╚══════════════════════════════════════════════════════════════╝

SCAN INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target Domain:     $DOMAIN
Scan Date:         $(date)
Scan Duration:     $((SECONDS / 60)) minutes $((SECONDS % 60)) seconds
Output Directory:  $OUTPUT_DIR

STATISTICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
JS Files Discovered:   $js_count
Files Successfully
  Downloaded:          $scanned_count
Potential Secrets
  Discovered:          $secrets_count

CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Threads Used:          $THREADS
Timeout per Request:   ${TIMEOUT}s
Max File Size:         $((MAX_FILE_SIZE / 1024 / 1024))MB
Wayback Machine:       $([ "$NO_WAYBACK" != true ] && echo "Enabled" || echo "Disabled")
Crawling:              $([ "$NO_CRAWL" != true ] && echo "Enabled" || echo "Disabled")

EOF
    
    if [ $secrets_count -gt 0 ]; then
        cat >> "$REPORT_FILE" << EOF
SECRETS FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
        cat "$SECRETS_FILE" >> "$REPORT_FILE"
        
        # Generate JSON output if requested
        if [ "$JSON_OUTPUT" = true ]; then
            generate_json_report
        fi
        
        # Show summary of secret types
        echo -e "\n${YELLOW}Secret Types Found:${NC}"
        grep -o "found in:" "$SECRETS_FILE" | sort | uniq -c | while read count type; do
            echo -e "  ${GREEN}➜${NC} $count potential secrets"
        done
    else
        cat >> "$REPORT_FILE" << EOF
SECRETS FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
No secrets were discovered in the JavaScript files.

Note: This doesn't guarantee the target is secure. Consider:
- Using custom regex patterns (--regex)
- Increasing crawl depth (--depth)
- Manual review of downloaded files

EOF
    fi
    
    cat >> "$REPORT_FILE" << EOF

OUTPUT FILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
JS URLs List:        $JS_URLS_FILE
Downloaded Files:    $OUTPUT_DIR/downloads/
Secrets Found:       $SECRETS_FILE
Full Report:         $REPORT_FILE

NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Review the secrets.txt file for false positives
2. Verify valid credentials before reporting
3. Check downloaded JS files manually for obfuscated secrets
4. Run with custom regex patterns for targeted scanning

EOF
    
    # Display report
    cat "$REPORT_FILE"
    
    log_success "Report saved: $REPORT_FILE"
}

# Generate JSON report
generate_json_report() {
    local json_file="$OUTPUT_DIR/report.json"
    
    cat > "$json_file" << EOF
{
  "scan_info": {
    "domain": "$DOMAIN",
    "timestamp": "$(date -Iseconds)",
    "duration_seconds": $SECONDS,
    "output_directory": "$OUTPUT_DIR"
  },
  "statistics": {
    "js_files_discovered": $(wc -l < "$JS_URLS_FILE"),
    "files_downloaded": $(ls -1 "$OUTPUT_DIR/downloads/" 2>/dev/null | wc -l),
    "potential_secrets": $(grep -c "found in:" "$SECRETS_FILE" 2>/dev/null || echo 0)
  },
  "secrets": $(python3 -c "import json; secrets = open('$SECRETS_FILE').read() if open('$SECRETS_FILE').read() else '[]'; print(json.dumps(secrets.split('---')))" 2>/dev/null || echo "[]")
}
EOF
    
    log_success "JSON report generated: $json_file"
}

# Cleanup function
cleanup() {
    rm -f "$JS_URLS_TEMP" 2>/dev/null
    log_debug "Cleaned up temporary files"
}

# Parse arguments
parse_args() {
    DOMAIN=""
    OUTPUT_DIR=""
    DEPTH=2
    NO_WAYBACK=false
    NO_CRAWL=false
    NO_DOWNLOAD=false
    CUSTOM_REGEX=""
    QUIET=false
    JSON_OUTPUT=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -t|--threads)
                THREADS="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -d|--depth)
                DEPTH="$2"
                shift 2
                ;;
            -f|--file)
                DOMAIN_FILE="$2"
                shift 2
                ;;
            --no-wayback)
                NO_WAYBACK=true
                shift
                ;;
            --no-crawl)
                NO_CRAWL=true
                shift
                ;;
            --no-download)
                NO_DOWNLOAD=true
                shift
                ;;
            --regex)
                CUSTOM_REGEX="$2"
                shift 2
                ;;
            --quiet)
                QUIET=true
                shift
                ;;
            --json)
                JSON_OUTPUT=true
                shift
                ;;
            *)
                DOMAIN="$1"
                shift
                ;;
        esac
    done
    
    # Handle domain file
    if [ -n "${DOMAIN_FILE:-}" ] && [ -f "$DOMAIN_FILE" ]; then
        DOMAIN=$(head -n1 "$DOMAIN_FILE")
        log_info "Using first domain from file: $DOMAIN"
    fi
    
    if [ -z "$DOMAIN" ]; then
        log_error "No domain specified"
        show_help
    fi
    
    # Set output directory
    if [ -z "$OUTPUT_DIR" ]; then
        OUTPUT_DIR="js_secrets_${DOMAIN}_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Set file paths
    JS_URLS_TEMP="$OUTPUT_DIR/js_urls_temp.txt"
    JS_URLS_FILE="$OUTPUT_DIR/js_urls.txt"
    SECRETS_FILE="$OUTPUT_DIR/secrets.txt"
    REPORT_FILE="$OUTPUT_DIR/REPORT.txt"
}

# Main execution
main() {
    banner
    
    # Parse command line arguments
    parse_args "$@"
    
    # Start timer
    SECONDS=0
    
    log_success "Target: $DOMAIN"
    log_success "Output: $OUTPUT_DIR"
    
    # Setup cleanup trap
    trap cleanup EXIT
    
    # Execute scanning pipeline
    check_tools
    discover_js
    
    if [ "$NO_DOWNLOAD" != true ]; then
        download_and_scan
    else
        log_warning "Skipping download and scan phase"
    fi
    
    generate_report
    
    echo ""
    log_success "✅ Scan Complete! Time elapsed: $((SECONDS / 60))m $((SECONDS % 60))s"
    echo ""
    log_info "Review findings: cat $SECRETS_FILE"
    log_info "View report: cat $REPORT_FILE"
    
    if [ "$JSON_OUTPUT" = true ]; then
        log_info "JSON report: cat $OUTPUT_DIR/report.json | jq ."
    fi
}

# Run main function
main "$@"
EOF

# Make script executable
chmod +x js-secret-scanner.sh

# Create enhanced README
cat > README.md << 'EOF'
# 🔍 JS Secret Scanner - Professional Edition

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/tryme-devv/js-secret-scanner)
[![Bash](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-red.svg)](LICENSE)

**Automated JavaScript Secret Discovery Tool** - Find hardcoded API keys, tokens, credentials, and sensitive data in JavaScript files at scale.

## ✨ Features

- 🚀 **Multi-threaded scanning** (configurable up to 20+ threads)
- 🔍 **Multiple discovery methods** (Wayback Machine, crawling, CDN patterns)
- 📊 **Comprehensive reporting** (text & JSON formats)
- 🎯 **Advanced pattern matching** (40+ secret patterns)
- 💾 **Smart file handling** (size limits, timeouts, validation)
- 📈 **Real-time progress tracking**
- 🛡️ **Safe file downloading** (no oversized files)
- 🔄 **Parallel processing** for maximum performance
- 📝 **Detailed statistics** and visual formatting

## 🚀 Quick Install

```bash
# Clone repository
git clone https://github.com/tryme-devv/js-secret-scanner.git
cd js-secret-scanner

# Make executable
chmod +x js-secret-scanner.sh

# Run
./js-secret-scanner.sh example.com
