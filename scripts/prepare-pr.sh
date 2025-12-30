#!/bin/bash
# Prepare server for PR submission to docker/mcp-registry
# Usage: ./scripts/prepare-pr.sh <server-name>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SERVERS_DIR="$ROOT_DIR/servers"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "Usage: $0 <server-name>"
    exit 1
fi

SERVER_NAME="$1"
SERVER_DIR="$SERVERS_DIR/$SERVER_NAME"
OUTPUT_DIR="$ROOT_DIR/pr-output/$SERVER_NAME"

if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server '$SERVER_NAME' not found${NC}"
    exit 1
fi

echo -e "${BLUE}Preparing $SERVER_NAME for PR submission...${NC}"
echo ""

# Step 1: Validate
echo "Step 1: Validating configuration..."
if ! "$SCRIPT_DIR/validate.sh" "$SERVER_NAME"; then
    echo -e "${RED}Validation failed. Fix errors before submitting PR.${NC}"
    exit 1
fi

# Step 2: Build Docker image
echo ""
echo "Step 2: Building Docker image..."
docker build -t "mcp/$SERVER_NAME:pr" "$SERVER_DIR"
echo -e "${GREEN}✓ Image built successfully${NC}"

# Step 3: Create output directory
echo ""
echo "Step 3: Preparing PR files..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy required files
cp "$SERVER_DIR/server.yaml" "$OUTPUT_DIR/"
cp "$SERVER_DIR/tools.json" "$OUTPUT_DIR/" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/tools.json"

# Note: Dockerfile stays in source repo, not registry
echo -e "${GREEN}✓ Files prepared in: $OUTPUT_DIR${NC}"

# Step 4: Generate PR checklist
echo ""
echo "Step 4: Generating PR checklist..."

cat > "$OUTPUT_DIR/PR_CHECKLIST.md" << 'EOF'
# PR Submission Checklist

## Before Submitting

- [ ] Server configuration validated locally
- [ ] Docker image builds successfully
- [ ] Tools documented in tools.json
- [ ] Source repository has Dockerfile at root
- [ ] License is MIT, Apache 2.0, or BSD
- [ ] Commit hash specified in server.yaml

## Files to Submit

Copy these files to your docker/mcp-registry fork:

```
servers/SERVER_NAME/
├── server.yaml
└── tools.json
```

## PR Description Template

```markdown
## New Server: SERVER_NAME

### Description
Brief description of what this server does.

### Source Repository
Link to source: https://github.com/owner/repo

### License
MIT

### Testing
- [ ] Built Docker image locally
- [ ] Tested tools work correctly
- [ ] Validated with `task validate`

### Checklist
- [ ] I have read the CONTRIBUTING.md
- [ ] Server follows registry conventions
- [ ] No secrets or credentials in configuration
```

## Submission Steps

1. Fork docker/mcp-registry if not already done
2. Create new branch: `git checkout -b add-SERVER_NAME`
3. Copy files: `cp -r pr-output/SERVER_NAME ../mcp-registry/servers/`
4. Commit: `git add . && git commit -m "Add SERVER_NAME server"`
5. Push: `git push origin add-SERVER_NAME`
6. Open PR on GitHub
EOF

# Replace SERVER_NAME placeholder
sed -i.bak "s/SERVER_NAME/$SERVER_NAME/g" "$OUTPUT_DIR/PR_CHECKLIST.md"
rm -f "$OUTPUT_DIR/PR_CHECKLIST.md.bak"

echo -e "${GREEN}✓ PR checklist created${NC}"

# Summary
echo ""
echo "============================="
echo -e "${GREEN}PR preparation complete!${NC}"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Files ready for submission:"
ls -la "$OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Review PR_CHECKLIST.md"
echo "  2. Fork docker/mcp-registry"
echo "  3. Copy files to your fork"
echo "  4. Submit PR"
