# Security Evaluation Criteria for MCP Servers

This document outlines the security evaluation criteria for third-party MCP servers before adding them to this registry or recommending them for use.

## Overview

MCP servers often require access to sensitive credentials (API keys, OAuth tokens) and can interact with external services on your behalf. Thorough security evaluation is essential before trusting any MCP server with your data.

## Evaluation Framework

### 1. License & Legal Compliance

#### Required
- [ ] **Open Source License** - Source code must be publicly available
- [ ] **Permissive License** - MIT, Apache 2.0, or BSD preferred
- [ ] **Clear Attribution** - License requirements are documented

#### Red Flags
- GPL or AGPL licenses (may have compatibility issues)
- Proprietary or "source available" licenses
- No license file in repository
- License that restricts containerization or distribution

### 2. Repository Health

#### Required
- [ ] **Active Maintenance** - Commits within the last 6 months
- [ ] **Issue Response** - Maintainer responds to issues/PRs
- [ ] **Version Releases** - Tagged releases with changelogs
- [ ] **Documentation** - Clear README with setup instructions

#### Scoring Guide
| Metric | Good | Acceptable | Concerning |
|--------|------|------------|------------|
| Last commit | < 1 month | < 6 months | > 6 months |
| Open issues | Triaged | Some stale | Many abandoned |
| Stars | > 100 | > 20 | < 10 |
| Contributors | > 3 | > 1 | Single person |

### 3. Credential Security

#### Required
- [ ] **Local Storage Only** - Credentials never transmitted to third parties
- [ ] **No Hardcoding** - No credentials in source code
- [ ] **Secure Defaults** - Safe default configurations
- [ ] **Documentation** - Clear credential handling documentation

#### Verification Steps

1. **Search source for credential patterns:**
   ```bash
   grep -rn "api_key\|secret\|password\|token" --include="*.ts" --include="*.js"
   ```

2. **Check for outbound connections:**
   ```bash
   grep -rn "fetch\|axios\|http\|https" --include="*.ts" --include="*.js"
   ```

3. **Review OAuth implementation:**
   - Tokens stored locally (e.g., `~/.config/`)
   - No cloud storage of credentials
   - Proper token refresh handling

### 4. Code Quality & Security

#### Required
- [ ] **No Known Vulnerabilities** - No critical CVEs
- [ ] **Dependency Audit** - Dependencies are up to date
- [ ] **Input Validation** - User inputs are validated
- [ ] **Error Handling** - Errors don't leak sensitive info

#### Verification Steps

1. **Audit dependencies:**
   ```bash
   npm audit
   # or
   yarn audit
   ```

2. **Check for vulnerable patterns:**
   - SQL injection in database queries
   - Command injection in shell executions
   - Path traversal in file operations
   - XSS in any web components

3. **Review error handling:**
   - Stack traces don't expose paths
   - Error messages don't leak credentials
   - Failures are logged safely

### 5. Data Privacy

#### Required
- [ ] **Minimal Data Access** - Only requests necessary permissions
- [ ] **No Telemetry** - No usage tracking without consent
- [ ] **Data Locality** - Data processed locally when possible
- [ ] **Clear Scope** - OAuth scopes are minimal and documented

#### Questions to Answer
- What data does the server access?
- Where is data processed?
- Is data ever transmitted externally?
- What OAuth scopes are requested and why?

### 6. Container Security

#### Required
- [ ] **Minimal Base Image** - Uses slim/alpine images
- [ ] **Non-Root User** - Runs as non-root when possible
- [ ] **No Privileged Mode** - Doesn't require --privileged
- [ ] **Limited Volumes** - Only mounts necessary directories

#### Dockerfile Review Checklist
```dockerfile
# Good practices
FROM node:20-slim          # Minimal base image
USER node                  # Non-root user
WORKDIR /app               # Explicit workdir
COPY --chown=node:node .   # Proper ownership

# Red flags
FROM ubuntu:latest         # Large, potentially outdated
USER root                  # Running as root
--privileged               # Elevated privileges
-v /:/host                 # Excessive volume mounts
```

## Risk Levels

### Low Risk (Green Light)
- MIT/Apache 2.0 licensed
- Active maintenance (< 3 months)
- > 100 stars, multiple contributors
- Clear credential handling
- No external data transmission
- Minimal OAuth scopes

### Medium Risk (Proceed with Caution)
- Less common open source license
- Maintenance within 6 months
- 20-100 stars, single maintainer
- Credentials handled locally
- Some telemetry (opt-out available)

### High Risk (Not Recommended)
- No license or restrictive license
- Abandoned (> 6 months no activity)
- < 20 stars, unknown maintainer
- Unclear credential handling
- Data transmitted externally
- Excessive permissions requested

## Evaluation Template

Use this template when evaluating a new MCP server:

```markdown
## Server Evaluation: [Server Name]

**Repository:** [URL]
**License:** [License Type]
**Last Commit:** [Date]
**Stars:** [Count]

### Checklist

#### License & Legal
- [ ] Open source license
- [ ] Permissive (MIT/Apache/BSD)
- [ ] Clear attribution

#### Repository Health
- [ ] Active maintenance
- [ ] Responsive maintainer
- [ ] Versioned releases
- [ ] Good documentation

#### Credential Security
- [ ] Local storage only
- [ ] No hardcoded secrets
- [ ] Secure defaults

#### Code Quality
- [ ] No known CVEs
- [ ] Clean dependencies
- [ ] Input validation
- [ ] Safe error handling

#### Data Privacy
- [ ] Minimal permissions
- [ ] No unauthorized telemetry
- [ ] Local processing

#### Container Security
- [ ] Minimal base image
- [ ] Non-root execution
- [ ] Limited volumes

### Risk Assessment

**Overall Risk Level:** [Low/Medium/High]

**Notes:**
[Additional observations]

### Recommendation

[ ] Approve for registry
[ ] Approve with conditions
[ ] Reject (reason: ___)
```

## Reporting Security Issues

If you discover a security vulnerability in any MCP server:

1. **Do not** open a public issue
2. Check for a SECURITY.md in the source repository
3. Contact the maintainer directly
4. If no response within 90 days, consider public disclosure
5. Update this registry to remove or warn about the server

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [npm Security Best Practices](https://docs.npmjs.com/packages-and-modules/securing-your-code)
- [Docker Security Guide](https://docs.docker.com/engine/security/)
- [MCP Security Considerations](https://modelcontextprotocol.io/docs/concepts/security)
