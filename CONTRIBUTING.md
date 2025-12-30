# Contributing Guide

This guide explains how to add new MCP servers to this personal registry and prepare contributions for the official [docker/mcp-registry](https://github.com/docker/mcp-registry).

## Table of Contents

- [Adding a New Server](#adding-a-new-server)
- [Server Configuration Files](#server-configuration-files)
- [Server Types](#server-types)
- [Testing Locally](#testing-locally)
- [Submitting to docker/mcp-registry](#submitting-to-dockermcp-registry)
- [Server Evaluation Checklist](#server-evaluation-checklist)

## Adding a New Server

### Step 1: Evaluate the Server

Before adding a new MCP server, evaluate it using our [Security Criteria](docs/SECURITY.md):

- [ ] License is permissive (MIT, Apache 2.0, BSD)
- [ ] Repository is actively maintained (commits within last 6 months)
- [ ] Has reasonable star count or community adoption
- [ ] No known security vulnerabilities
- [ ] Clear documentation for setup and usage
- [ ] Credentials are handled securely (local storage, not transmitted)

### Step 2: Create Server Directory

```bash
# Copy the template
cp -r servers/_template servers/your-server-name

# Navigate to the new directory
cd servers/your-server-name
```

### Step 3: Configure the Server

Edit the following files:

1. **server.yaml** - Main configuration
2. **tools.json** - Tool definitions (can be empty `[]` for dynamic discovery)
3. **Dockerfile** - Container build instructions
4. **README.md** - Server-specific documentation

### Step 4: Test Locally

```bash
# Validate configuration
make validate SERVER=your-server-name

# Build the Docker image
make build SERVER=your-server-name

# Test the server
make test SERVER=your-server-name
```

### Step 5: Document

Update the server's README.md with:
- Purpose and capabilities
- Setup instructions (OAuth, API keys, etc.)
- Usage examples
- Troubleshooting tips

## Server Configuration Files

### server.yaml

The main configuration file following Docker MCP Registry spec:

```yaml
# Required fields
name: your-server-name           # Unique identifier (lowercase, hyphens)
type: server                     # 'server' for local, 'remote' for hosted
image: mcp/your-server-name      # Docker image name

# Metadata
meta:
  category: communication        # Primary category
  tags:                          # Searchable tags
    - email
    - oauth
    - automation

# Display information
about:
  title: Your Server Title
  description: >
    A brief description of what this server does
    and its key capabilities.
  icon: https://example.com/icon.png  # 256x256 PNG preferred

# Source repository
source:
  project: https://github.com/owner/repo
  commit: abc123def456             # Specific commit hash

# Configuration for secrets and environment
config:
  description: |
    Setup instructions shown to users during configuration.

    1. First step
    2. Second step

  # Secrets stored securely by Docker
  secrets:
    - name: your-server.api_key
      env: API_KEY
      example: sk-your-api-key-here

  # Environment variables
  env:
    - name: LOG_LEVEL
      example: info
      value: "{{your-server.log_level}}"

  # JSON Schema for additional parameters
  parameters:
    type: object
    properties:
      timeout:
        type: integer
        default: 30
    required: []
```

### tools.json

Define the tools exposed by your server:

```json
[
  {
    "name": "tool_name",
    "description": "What this tool does",
    "arguments": [
      {
        "name": "param1",
        "type": "string",
        "desc": "Parameter description",
        "required": true
      },
      {
        "name": "param2",
        "type": "boolean",
        "desc": "Optional parameter",
        "required": false
      }
    ]
  }
]
```

**Note:** For servers with dynamic tool discovery, use an empty array `[]`.

### Dockerfile

Standard Dockerfile for containerizing the MCP server:

```dockerfile
FROM node:20-slim

WORKDIR /app

# Install the MCP server package
RUN npm install -g @package/mcp-server

# Create directory for credentials
RUN mkdir -p /root/.config

# Set entrypoint
ENTRYPOINT ["npx", "@package/mcp-server"]
```

## Server Types

### Local Servers (type: server)

Containerized servers that run locally via Docker:

- Full control over the runtime environment
- Credentials stored locally
- Requires Dockerfile
- Published to Docker Hub `mcp/` namespace (for official registry)

### Remote Servers (type: remote)

Hosted servers accessed via HTTP/SSE:

```yaml
name: remote-server
type: remote
dynamic:
  tools: true                    # Tools discovered dynamically

remote:
  transport_type: streamable-http  # or 'sse'
  url: https://mcp.example.com/endpoint

# OAuth configuration (if needed)
oauth:
  - provider: service-name
    secret: service.access_token
    env: ACCESS_TOKEN
```

## Testing Locally

### Validate Configuration

```bash
# Validate a specific server
make validate SERVER=your-server-name

# Validate all servers
make validate-all
```

### Build and Run

```bash
# Build Docker image
make build SERVER=your-server-name

# Run interactively
make run SERVER=your-server-name

# Test with docker mcp
docker mcp add ./servers/your-server-name
```

### Test Tools

```bash
# List tools exposed by the server
make tools SERVER=your-server-name
```

## Submitting to docker/mcp-registry

### Prepare Your Contribution

1. **Fork the official registry:**
   ```bash
   gh repo fork docker/mcp-registry
   ```

2. **Generate PR files:**
   ```bash
   make prepare-pr SERVER=your-server-name
   ```

3. **Copy to your fork:**
   ```bash
   cp -r servers/your-server-name ../mcp-registry/servers/
   ```

4. **Submit PR:**
   - Follow the official [CONTRIBUTING.md](https://github.com/docker/mcp-registry/blob/main/CONTRIBUTING.md)
   - Include testing evidence
   - Reference the source repository

### PR Checklist

Before submitting:

- [ ] Server validates locally (`make validate`)
- [ ] Docker image builds successfully (`make build`)
- [ ] Tools are documented in tools.json
- [ ] README includes setup instructions
- [ ] License is compatible (MIT/Apache 2.0)
- [ ] Source commit hash is specified
- [ ] All secrets are properly configured

## Server Evaluation Checklist

Use this checklist when evaluating a new MCP server:

### License & Legal
- [ ] Open source license (MIT, Apache 2.0, BSD preferred)
- [ ] No GPL or restrictive licenses
- [ ] Clear attribution requirements

### Security
- [ ] No hardcoded credentials in source
- [ ] Credentials stored locally, not transmitted
- [ ] No known CVEs or security issues
- [ ] Handles sensitive data appropriately

### Maintenance
- [ ] Active repository (commits within 6 months)
- [ ] Responsive maintainer (issues addressed)
- [ ] Clear versioning and releases
- [ ] Good documentation

### Quality
- [ ] Reasonable test coverage
- [ ] No major open bugs
- [ ] Works with current MCP SDK version
- [ ] Clean dependencies (no abandoned packages)

### Community
- [ ] Star count indicates adoption
- [ ] Active discussions/issues
- [ ] Multiple contributors (not single person)
- [ ] Used in production by others

## Categories

When setting the `meta.category` field, use one of these standard categories:

| Category | Description |
|----------|-------------|
| `communication` | Email, messaging, notifications |
| `database` | Database connections and queries |
| `productivity` | Task management, notes, calendars |
| `development` | Code analysis, git, CI/CD |
| `cloud` | Cloud provider integrations |
| `ai` | AI/ML services and models |
| `data` | Data processing and analytics |
| `documentation` | Docs, knowledge bases |
| `security` | Security tools and scanning |
| `media` | Images, video, audio |

## Getting Help

- Review existing servers in `servers/` for examples
- Check the [Docker MCP Registry](https://github.com/docker/mcp-registry) for official patterns
- Open an issue in this repository for questions
