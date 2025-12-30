# Gmail MCP Server with OAuth 2.0
# Source: https://github.com/GongRzhe/Gmail-MCP-Server
# Package: @gongrzhe/server-gmail-autoauth-mcp

FROM node:20-slim

WORKDIR /app

# Install the Gmail MCP server package
RUN npm install -g @gongrzhe/server-gmail-autoauth-mcp

# Create directory for Gmail credentials
# The server stores OAuth tokens in ~/.gmail-mcp/
RUN mkdir -p /root/.gmail-mcp

# Volume mount point for credential persistence
# Mount your local ~/.gmail-mcp directory here
VOLUME ["/root/.gmail-mcp"]

# Set environment for production
ENV NODE_ENV=production

# Run the server directly (faster than npx)
ENTRYPOINT ["gmail-mcp"]
