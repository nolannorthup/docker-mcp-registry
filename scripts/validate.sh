#!/bin/bash
# Validate MCP server configurations
# Usage: ./scripts/validate.sh [server-name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SERVERS_DIR="$ROOT_DIR/servers"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warn() { echo -e "${YELLOW}!${NC} $1"; }
log_info() { echo -e "  $1"; }

validate_yaml() {
    local file="$1"
    if command -v node &> /dev/null; then
        node -e "
            const yaml = require('js-yaml');
            const fs = require('fs');
            try {
                const doc = yaml.load(fs.readFileSync('$file', 'utf8'));
                if (!doc.name) throw new Error('Missing: name');
                if (!doc.type) throw new Error('Missing: type');
                if (!doc.about?.title) throw new Error('Missing: about.title');
                if (!doc.about?.description) throw new Error('Missing: about.description');
                process.exit(0);
            } catch (e) {
                console.error(e.message);
                process.exit(1);
            }
        " 2>&1
    else
        # Fallback: basic YAML syntax check with Python
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>&1
    fi
}

validate_json() {
    local file="$1"
    if command -v node &> /dev/null; then
        node -e "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" 2>&1
    else
        python3 -c "import json; json.load(open('$file'))" 2>&1
    fi
}

validate_dockerfile() {
    local file="$1"
    # Basic checks
    if ! grep -q "^FROM" "$file"; then
        echo "Missing FROM instruction"
        return 1
    fi
    if ! grep -q "ENTRYPOINT\|CMD" "$file"; then
        echo "Missing ENTRYPOINT or CMD"
        return 1
    fi
    return 0
}

validate_server() {
    local server_dir="$1"
    local server_name="$(basename "$server_dir")"
    local errors=0

    echo ""
    echo "Validating: $server_name"
    echo "----------------------------"

    # Check server.yaml
    if [ -f "$server_dir/server.yaml" ]; then
        if result=$(validate_yaml "$server_dir/server.yaml"); then
            log_success "server.yaml is valid"
        else
            log_error "server.yaml: $result"
            ((errors++))
        fi
    else
        log_error "server.yaml not found"
        ((errors++))
    fi

    # Check tools.json
    if [ -f "$server_dir/tools.json" ]; then
        if result=$(validate_json "$server_dir/tools.json"); then
            log_success "tools.json is valid"
        else
            log_error "tools.json: $result"
            ((errors++))
        fi
    else
        log_warn "tools.json not found (optional for dynamic discovery)"
    fi

    # Check Dockerfile
    if [ -f "$server_dir/Dockerfile" ]; then
        if result=$(validate_dockerfile "$server_dir/Dockerfile"); then
            log_success "Dockerfile is valid"
        else
            log_error "Dockerfile: $result"
            ((errors++))
        fi
    else
        log_warn "Dockerfile not found"
    fi

    # Check README
    if [ -f "$server_dir/README.md" ]; then
        log_success "README.md exists"
    else
        log_warn "README.md not found (recommended)"
    fi

    return $errors
}

# Main
total_errors=0

if [ -n "$1" ]; then
    # Validate specific server
    server_dir="$SERVERS_DIR/$1"
    if [ -d "$server_dir" ]; then
        validate_server "$server_dir"
        total_errors=$?
    else
        log_error "Server not found: $1"
        exit 1
    fi
else
    # Validate all servers
    echo "Validating all MCP servers..."

    for server_dir in "$SERVERS_DIR"/*/; do
        server_name="$(basename "$server_dir")"

        # Skip template
        if [ "$server_name" = "_template" ]; then
            continue
        fi

        validate_server "$server_dir"
        ((total_errors+=$?))
    done
fi

echo ""
echo "============================="
if [ $total_errors -eq 0 ]; then
    log_success "All validations passed!"
    exit 0
else
    log_error "$total_errors validation error(s) found"
    exit 1
fi
