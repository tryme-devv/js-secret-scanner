#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║     JS Secret Hunter - Automated Secret Discovery        ║
║            Finds secrets in JavaScript files             ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check domain
if [ -z "$1" ]; then
    echo -e "${RED}[-] Usage: $0 <domain>${NC}"
    echo -e "${YELLOW}[+] Example: $0 example.com${NC}"
    exit 1
fi

DOMAIN="$1"
OUTPUT_DIR="js_secrets_${DOMAIN}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[+] Target: $DOMAIN${NC}"
echo -e "${GREEN}[+] Output: $OUTPUT_DIR${NC}"

# Check and install tools
check_tools() {
    echo -e "${BLUE}[*] Checking tools...${NC}"
    
    if ! command -v go &> /dev/null; then
        echo -e "${RED}[-] Go not installed. Please install Go first.${NC}"
        exit 1
    fi
    
    # Install waybackurls
    if ! command -v waybackurls &> /dev/null; then
        echo -e "${YELLOW}[+] Installing waybackurls...${NC}"
        go install github.com/tomnomnom/waybackurls@latest 2>/dev/null
        export PATH=$PATH:$(go env GOPATH)/bin
    fi
    
    echo -e "${GREEN}[+] Tools ready${NC}"
}

# Discover JS files
discover_js() {
    echo -e "${BLUE}[*] Discovering JS files...${NC}"
    
    echo "$DOMAIN" | waybackurls 2>/dev/null | grep -E "\.js($|\?)|\.jsx" | sort -u > "$OUTPUT_DIR/js_urls.txt"
    
    COUNT=$(wc -l < "$OUTPUT_DIR/js_urls.txt")
    echo -e "${GREEN}[+] Found $COUNT JS files${NC}"
    
    if [ "$COUNT" -eq 0 ]; then
        echo -e "${RED}[-] No JS files found${NC}"
        exit 1
    fi
}

# Download and scan
download_and_scan() {
    echo -e "${BLUE}[*] Scanning JS files...${NC}"
    
    mkdir -p "$OUTPUT_DIR/downloads"
    > "$OUTPUT_DIR/secrets.txt"
    
    TOTAL=$(wc -l < "$OUTPUT_DIR/js_urls.txt")
    CURRENT=0
    
    while IFS= read -r url; do
        CURRENT=$((CURRENT + 1))
        echo -ne "${CYAN}[$CURRENT/$TOTAL] Scanning...${NC}\r"
        
        filename=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g' | cut -c1-50)
        curl -s -L --max-time 10 "$url" -o "$OUTPUT_DIR/downloads/$filename.js" 2>/dev/null
        
        if [ -s "$OUTPUT_DIR/downloads/$filename.js" ]; then
            grep -H -i -n -E \
                -e "(api[_-]?key|apikey)" \
                -e "(access[_-]?token|auth_token|bearer)" \
                -e "secret|secretkey" \
                -e "password|passwd" \
                -e "aws[_-]?key|s3[_-]?key" \
                -e "firebase|google_api" \
                -e "github[_-]?token" \
                -e "jwt[_-]?secret" \
                -e "mongodb|postgresql|redis" \
                -e "private[_-]?key" \
                -e "slack[_-]?token|discord[_-]?token" \
                -e "stripe[_-]?(key|secret)" \
                "$OUTPUT_DIR/downloads/$filename.js" >> "$OUTPUT_DIR/secrets.txt" 2>/dev/null
        fi
    done < "$OUTPUT_DIR/js_urls.txt"
    
    echo ""
    echo -e "${GREEN}[+] Scan complete${NC}"
}

# Generate report
generate_report() {
    echo -e "${BLUE}[*] Generating report...${NC}"
    
    REPORT="$OUTPUT_DIR/REPORT.txt"
    
    {
        echo "JS SECRET SCANNER REPORT"
        echo "========================"
        echo "Domain: $DOMAIN"
        echo "Date: $(date)"
        echo ""
        echo "STATISTICS:"
        echo "- JS Files Found: $(wc -l < "$OUTPUT_DIR/js_urls.txt")"
        echo "- Files Downloaded: $(ls -1 "$OUTPUT_DIR/downloads/" 2>/dev/null | wc -l)"
        echo "- Secrets Found: $(grep -c "found in:" "$OUTPUT_DIR/secrets.txt" 2>/dev/null || echo 0)"
        echo ""
        echo "SECRETS FOUND:"
        echo "=============="
        cat "$OUTPUT_DIR/secrets.txt" 2>/dev/null || echo "No secrets found"
        echo ""
        echo "OUTPUT FILES:"
        echo "- JS URLs: $OUTPUT_DIR/js_urls.txt"
        echo "- Downloads: $OUTPUT_DIR/downloads/"
        echo "- Secrets: $OUTPUT_DIR/secrets.txt"
    } > "$REPORT"
    
    cat "$REPORT"
    echo -e "${GREEN}[+] Report saved: $REPORT${NC}"
}

# Main execution
main() {
    check_tools
    discover_js
    download_and_scan
    generate_report
    
    echo ""
    echo -e "${GREEN}✅ Scan Complete!${NC}"
}

main
