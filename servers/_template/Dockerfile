# MCP Server Dockerfile Template
# Customize this for your specific MCP server

# Use a minimal base image
# Options: node:20-slim, python:3.12-slim, golang:1.22-alpine
FROM node:20-slim

# Set working directory
WORKDIR /app

# Install system dependencies if needed
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# Install the MCP server package
# For npm packages:
RUN npm install -g @package/mcp-server-name

# For Python packages:
# RUN pip install --no-cache-dir mcp-server-name

# Create directories for configuration/credentials
# Adjust path based on where the server stores config
RUN mkdir -p /root/.config/mcp-server

# Set environment variables if needed
# ENV NODE_ENV=production

# The entrypoint should be the MCP server command
# Adjust based on how the server is invoked
ENTRYPOINT ["npx", "@package/mcp-server-name"]

# Alternative entrypoints:
# ENTRYPOINT ["python", "-m", "mcp_server"]
# ENTRYPOINT ["mcp-server-binary"]
