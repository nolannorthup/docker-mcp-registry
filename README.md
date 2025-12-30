# Docker MCP Registry - Personal Collection

A personal collection of custom MCP (Model Context Protocol) server configurations for the [Docker MCP Toolkit](https://docs.docker.com/desktop/features/mcp-catalog-and-toolkit/). This repository contains containerized MCP servers that I contribute to or create, following the official [docker/mcp-registry](https://github.com/docker/mcp-registry) conventions.

## Purpose

This repository serves as:

1. **Development Workspace** - Build and test MCP server configurations locally before submitting PRs to the official Docker MCP Registry
2. **Personal Catalog** - Maintain custom server configurations for projects like [AskLater](https://github.com/nolannorthup/asklater) (content aggregation system)
3. **Template Library** - Reusable templates and automation for quickly adding new MCP servers

## Repository Structure

```
docker-mcp-registry/
├── servers/                    # Individual MCP server configurations
│   ├── _template/              # Template for creating new servers
│   │   ├── server.yaml         # Configuration template
│   │   ├── tools.json          # Tools definition template
│   │   ├── Dockerfile          # Dockerfile template
│   │   └── README.md           # Server documentation template
│   └── gmail-oauth/            # Gmail MCP Server with OAuth
│       ├── server.yaml
│       ├── tools.json
│       ├── Dockerfile
│       └── README.md
├── docs/                       # Documentation
│   ├── SECURITY.md             # Security evaluation criteria
│   └── server-guides/          # Per-server setup guides
├── scripts/                    # Automation scripts
│   ├── validate.sh             # Validate server configurations
│   ├── test-local.sh           # Test servers locally
│   └── prepare-pr.sh           # Prepare PR for docker/mcp-registry
├── .github/workflows/          # GitHub Actions
│   └── validate.yml            # CI validation workflow
├── Makefile                    # Common automation tasks
├── CONTRIBUTING.md             # Guide for adding new servers
└── README.md                   # This file
```

## Available Servers

| Server | Description | Status | Category |
|--------|-------------|--------|----------|
| [gmail-oauth](servers/gmail-oauth/) | Gmail integration with OAuth 2.0 | Ready | Communication |

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with MCP Toolkit enabled
- [Task](https://taskfile.dev/) or Make for automation (optional)

### Using a Server

1. **List available servers:**
   ```bash
   docker mcp list
   ```

2. **Add a server from this registry:**
   ```bash
   # From local development
   docker mcp add ./servers/gmail-oauth

   # Or test the configuration
   make test SERVER=gmail-oauth
   ```

3. **Validate configurations:**
   ```bash
   make validate
   ```

### Adding a New Server

1. Copy the template:
   ```bash
   cp -r servers/_template servers/my-new-server
   ```

2. Edit the configuration files following [CONTRIBUTING.md](CONTRIBUTING.md)

3. Test locally:
   ```bash
   make test SERVER=my-new-server
   ```

4. Prepare for PR submission:
   ```bash
   make prepare-pr SERVER=my-new-server
   ```

## Local Development

### Validate All Servers

```bash
make validate
```

### Test a Specific Server

```bash
make test SERVER=gmail-oauth
```

### Build Docker Image

```bash
make build SERVER=gmail-oauth
```

### Run Server Locally

```bash
make run SERVER=gmail-oauth
```

## Contributing to docker/mcp-registry

This repository is designed to streamline contributions to the official Docker MCP Registry:

1. **Develop locally** - Build and test your server configuration here
2. **Run validation** - Ensure it passes all checks: `make validate`
3. **Prepare PR** - Generate the files needed for submission: `make prepare-pr SERVER=<name>`
4. **Submit PR** - Fork docker/mcp-registry and submit your contribution

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed instructions.

## Server Evaluation Criteria

Before adding a third-party MCP server, evaluate it against our [security criteria](docs/SECURITY.md):

- License compatibility (MIT/Apache 2.0 preferred)
- Active maintenance and community
- Security practices and vulnerability disclosure
- Credential handling and data privacy

## License

This repository is licensed under the MIT License. Individual server configurations may reference projects with their own licenses - see each server's README for details.

## Related Projects

- [docker/mcp-registry](https://github.com/docker/mcp-registry) - Official Docker MCP Registry
- [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) - Reference MCP server implementations
- [Docker MCP Documentation](https://docs.docker.com/desktop/features/mcp-catalog-and-toolkit/)
