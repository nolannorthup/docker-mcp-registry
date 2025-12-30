# {{Server Name}} MCP Server

> Brief one-line description of what this server does.

## Overview

Longer description of the MCP server, its purpose, and key features. Explain what problems it solves and who would benefit from using it.

## Source Repository

- **Repository:** [{{owner}}/{{repo}}](https://github.com/{{owner}}/{{repo}})
- **License:** MIT
- **Stars:** {{count}}
- **npm Package:** `@package/mcp-server-name`

## Prerequisites

Before using this MCP server, you need:

1. **Requirement 1** - Description of what's needed
2. **Requirement 2** - Description of what's needed
3. **Docker Desktop** - With MCP Toolkit enabled

## Setup

### Step 1: Obtain Credentials

Explain how to get the necessary API keys, OAuth tokens, or other credentials.

1. Go to [Service Dashboard](https://example.com)
2. Create a new application
3. Generate an API key
4. Save the key securely

### Step 2: Configure the Server

```bash
# Add the server to Docker MCP
docker mcp add gmail-oauth

# Or from this repository
docker mcp add ./servers/{{server-name}}
```

### Step 3: Provide Credentials

When prompted, enter your credentials. They are stored securely by Docker Desktop.

## Available Tools

| Tool | Description |
|------|-------------|
| `tool_name` | What this tool does |
| `another_tool` | What this other tool does |

### Tool Details

#### `tool_name`

Detailed description of what this tool does and when to use it.

**Parameters:**
- `param1` (required): Description
- `param2` (optional): Description

**Example:**
```
Use tool_name to do something with param1="value"
```

## Usage Examples

### Example 1: Basic Usage

Description of a common use case.

```
Prompt: "Do something with this server"
Result: Description of expected result
```

### Example 2: Advanced Usage

Description of a more complex use case.

## Troubleshooting

### Common Issues

#### Issue: Authentication Failed

**Symptoms:** Error message about invalid credentials

**Solution:**
1. Verify your API key is correct
2. Check that the key has necessary permissions
3. Try regenerating the key

#### Issue: Connection Timeout

**Symptoms:** Server fails to respond

**Solution:**
1. Check your internet connection
2. Verify the service is not experiencing an outage
3. Try increasing the timeout value

## Security Considerations

- Credentials are stored locally by Docker Desktop
- The server only accesses data you explicitly request
- OAuth tokens are refreshed automatically
- See [SECURITY.md](../../docs/SECURITY.md) for evaluation criteria

## Contributing

To improve this server configuration:

1. Fork this repository
2. Make your changes
3. Test locally with `make test SERVER={{server-name}}`
4. Submit a pull request

## Related Resources

- [Original Repository](https://github.com/{{owner}}/{{repo}})
- [Docker MCP Documentation](https://docs.docker.com/desktop/features/mcp-catalog-and-toolkit/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
