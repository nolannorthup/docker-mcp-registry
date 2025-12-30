# Gmail OAuth MCP Server

> Gmail integration with OAuth 2.0 authentication for Claude and other MCP clients.

## Overview

This MCP server provides comprehensive Gmail access through the Model Context Protocol, enabling AI assistants to manage email through natural language commands. It supports sending, reading, searching, and organizing emails with full attachment support.

**Key Features:**
- Send emails with HTML formatting, CC/BCC, and attachments (up to 25MB)
- Search emails using Gmail's powerful search syntax
- Manage labels and organize messages
- Create automated filters for email processing
- Batch operations for bulk email management
- OAuth 2.0 with automatic token refresh

## Source Repository

- **Repository:** [GongRzhe/Gmail-MCP-Server](https://github.com/GongRzhe/Gmail-MCP-Server)
- **License:** MIT
- **Stars:** 879+
- **npm Package:** `@gongrzhe/server-gmail-autoauth-mcp`

## Prerequisites

1. **Google Cloud Project** with Gmail API enabled
2. **OAuth 2.0 Credentials** (Desktop application type)
3. **Docker Desktop** with MCP Toolkit enabled

## Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing)
3. Navigate to **APIs & Services** > **Library**
4. Search for "Gmail API" and click **Enable**

### Step 2: Create OAuth Credentials

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. If prompted, configure the OAuth consent screen:
   - Choose "External" user type
   - Add your email as a test user
4. Select **Desktop app** as the application type
5. Download the JSON credentials file
6. Rename to `gcp-oauth.keys.json`

### Step 3: Store Credentials

Create the Gmail MCP config directory and add your credentials:

```bash
# Create config directory
mkdir -p ~/.gmail-mcp

# Move your downloaded credentials
mv ~/Downloads/client_secret_*.json ~/.gmail-mcp/gcp-oauth.keys.json
```

### Step 4: Initial Authentication

Run the authentication flow to grant Gmail access:

```bash
# Using npx directly
npx @gongrzhe/server-gmail-autoauth-mcp auth

# Or using Docker (after building)
docker run -it --rm \
  -v ~/.gmail-mcp:/root/.gmail-mcp \
  -p 3000:3000 \
  mcp/gmail-oauth auth
```

This will:
1. Open a browser window
2. Ask you to sign in with Google
3. Request permission to access Gmail
4. Save the refresh token to `~/.gmail-mcp/credentials.json`

### Step 5: Add to Docker MCP

```bash
# From this repository
docker mcp add ./servers/gmail-oauth

# Or build and add manually
cd servers/gmail-oauth
docker build -t mcp/gmail-oauth .
```

## Available Tools

### Email Operations

| Tool | Description |
|------|-------------|
| `send_email` | Send email with optional HTML, CC/BCC, attachments |
| `draft_email` | Create a draft for later editing |
| `read_email` | Get full email content by message ID |
| `search_emails` | Search using Gmail syntax |
| `modify_email` | Add/remove labels from a message |
| `delete_email` | Permanently delete a message |

### Label Management

| Tool | Description |
|------|-------------|
| `list_email_labels` | List all labels |
| `create_label` | Create custom label |
| `update_label` | Modify label properties |
| `delete_label` | Remove custom label |
| `get_or_create_label` | Get or create if missing |

### Batch Operations

| Tool | Description |
|------|-------------|
| `batch_modify_emails` | Modify labels on multiple emails (up to 50/batch) |
| `batch_delete_emails` | Delete multiple emails at once |

### Filter Management

| Tool | Description |
|------|-------------|
| `create_filter` | Create filter with custom criteria |
| `list_filters` | List all filters |
| `get_filter` | Get filter details |
| `delete_filter` | Remove a filter |
| `create_filter_from_template` | Use predefined filter templates |

### Attachments

| Tool | Description |
|------|-------------|
| `download_attachment` | Save attachment to specified directory |

## Usage Examples

### Search for Unread Emails

```
Search for unread emails from the last week
```

Gmail search syntax: `is:unread newer_than:7d`

### Send an Email with Attachment

```
Send an email to user@example.com with subject "Monthly Report"
and attach the file at /data/report.pdf
```

### Organize Emails with Labels

```
Find all emails from newsletters@company.com and add the "Newsletters" label
```

### Create an Automated Filter

```
Create a filter to automatically label emails from github.com as "GitHub"
```

## Docker Configuration

### Building the Image

```bash
cd servers/gmail-oauth
docker build -t mcp/gmail-oauth .
```

### Running with Volume Mount

```bash
docker run -it --rm \
  -v ~/.gmail-mcp:/root/.gmail-mcp \
  mcp/gmail-oauth
```

### Docker Compose

```yaml
version: '3.8'
services:
  gmail-mcp:
    build: ./servers/gmail-oauth
    volumes:
      - ~/.gmail-mcp:/root/.gmail-mcp
    environment:
      - NODE_ENV=production
```

## Troubleshooting

### Authentication Failed

**Symptoms:** "Invalid credentials" or "Token expired" errors

**Solutions:**
1. Delete `~/.gmail-mcp/credentials.json` and re-authenticate
2. Verify `gcp-oauth.keys.json` is valid JSON
3. Check that Gmail API is enabled in your Google Cloud project

### Permission Denied

**Symptoms:** "Insufficient permissions" errors

**Solutions:**
1. Ensure your Google account is added as a test user (if app is in testing mode)
2. Re-run authentication to grant all required scopes
3. Check OAuth consent screen configuration

### Rate Limiting

**Symptoms:** "Rate limit exceeded" errors

**Solutions:**
1. Gmail API has quotas - wait and retry
2. For batch operations, the server auto-chunks to 50 messages
3. Consider adding delays between large operations

## Security Considerations

- **Credentials are stored locally** in `~/.gmail-mcp/`
- **Tokens are never transmitted** to third parties
- **OAuth scopes** request only Gmail access
- **Refresh tokens** are stored encrypted by the OS keychain when possible

See [SECURITY.md](../../docs/SECURITY.md) for our evaluation criteria.

## Use Cases

### Content Aggregation (AskLater)

Perfect for projects like AskLater that aggregate content from email:

```
Search for emails with label "ToRead" and extract article links
```

### Email Automation

Automate repetitive email tasks:

```
Find all emails older than 30 days in Promotions and archive them
```

### Newsletter Management

Organize incoming newsletters:

```
Create filters for my newsletter subscriptions and label them appropriately
```

## Related Resources

- [Gmail MCP Server Repository](https://github.com/GongRzhe/Gmail-MCP-Server)
- [Gmail API Documentation](https://developers.google.com/gmail/api)
- [Gmail Search Operators](https://support.google.com/mail/answer/7190)
- [Docker MCP Toolkit](https://docs.docker.com/desktop/features/mcp-catalog-and-toolkit/)
