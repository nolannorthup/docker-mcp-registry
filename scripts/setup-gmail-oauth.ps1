# Gmail OAuth MCP Server Setup Script for Windows
# Run this script to configure Gmail OAuth for Docker MCP Toolkit

$ErrorActionPreference = "Stop"

Write-Host "=== Gmail OAuth MCP Server Setup ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create credentials directory
$credDir = "$env:USERPROFILE\.gmail-mcp"
if (-not (Test-Path $credDir)) {
    Write-Host "Creating credentials directory: $credDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $credDir -Force | Out-Null
}

# Step 2: Check for OAuth keys
$oauthKeys = "$credDir\gcp-oauth.keys.json"
if (-not (Test-Path $oauthKeys)) {
    Write-Host ""
    Write-Host "OAuth credentials not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please complete these steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to Google Cloud Console:" -ForegroundColor White
    Write-Host "   https://console.cloud.google.com/" -ForegroundColor Blue
    Write-Host ""
    Write-Host "2. Create a new project or select existing one" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Enable the Gmail API:" -ForegroundColor White
    Write-Host "   - Go to 'APIs & Services' > 'Library'" -ForegroundColor Gray
    Write-Host "   - Search for 'Gmail API' and enable it" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Create OAuth credentials:" -ForegroundColor White
    Write-Host "   - Go to 'APIs & Services' > 'Credentials'" -ForegroundColor Gray
    Write-Host "   - Click 'Create Credentials' > 'OAuth client ID'" -ForegroundColor Gray
    Write-Host "   - Choose 'Desktop app' as application type" -ForegroundColor Gray
    Write-Host "   - Download the JSON file" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5. Save the downloaded file as:" -ForegroundColor White
    Write-Host "   $oauthKeys" -ForegroundColor Green
    Write-Host ""

    $response = Read-Host "Press Enter after you've saved the credentials file (or 'q' to quit)"
    if ($response -eq 'q') {
        exit 0
    }

    if (-not (Test-Path $oauthKeys)) {
        Write-Host "Credentials file still not found. Please save it and run this script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "OAuth credentials found!" -ForegroundColor Green

# Step 3: Run authentication
$credentialsFile = "$credDir\credentials.json"
if (-not (Test-Path $credentialsFile)) {
    Write-Host ""
    Write-Host "Running OAuth authentication flow..." -ForegroundColor Yellow
    Write-Host "A browser window will open for you to authorize Gmail access." -ForegroundColor Gray
    Write-Host ""

    npx @gongrzhe/server-gmail-autoauth-mcp auth

    if (-not (Test-Path $credentialsFile)) {
        Write-Host "Authentication may have failed. Check the browser and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Authentication complete!" -ForegroundColor Green

# Step 4: Verify Docker image exists
Write-Host ""
Write-Host "Checking Docker image..." -ForegroundColor Yellow
$imageExists = docker images mcp/gmail-oauth --format "{{.Repository}}" 2>$null
if (-not $imageExists) {
    Write-Host "Building Docker image..." -ForegroundColor Yellow
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptDir
    docker build -t mcp/gmail-oauth:latest "$repoRoot\servers\gmail-oauth"
}
Write-Host "Docker image ready!" -ForegroundColor Green

# Step 5: Add to Docker MCP catalog
Write-Host ""
Write-Host "Configuring Docker MCP Toolkit..." -ForegroundColor Yellow

# Check if catalog exists
$catalogs = docker mcp catalog ls 2>&1
if ($catalogs -notmatch "nolan-mcp") {
    docker mcp catalog create nolan-mcp 2>$null
}

# Add/update the server
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
docker mcp catalog add nolan-mcp gmail-oauth "$repoRoot\catalog.yaml" --force 2>$null

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Gmail OAuth MCP Server is ready to use with Docker MCP Toolkit." -ForegroundColor White
Write-Host ""
Write-Host "To use with Claude Code, run:" -ForegroundColor Yellow
Write-Host "  docker mcp gateway run --additional-catalog nolan-mcp.yaml --servers gmail-oauth" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or configure your MCP client to use the gateway." -ForegroundColor Gray
