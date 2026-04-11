---
name: security-check
description: Security audit with scorecard — scans for secrets, injection, XSS, auth gaps, and dependency vulnerabilities
model-hint: sonnet
---

# Security Check — Project Security Audit

Run a security review of the codebase with reference IDs for tracking fixes across sessions.

## Step 1: Static Analysis

Launch 2 parallel agents:

### Agent 1: Code Scanning (Explore agent)
Search all source files for:

**Hardcoded Secrets (AUTH-01 through AUTH-05):**
- API keys, tokens, passwords in source code (not .env)
- Hardcoded connection strings
- Private keys or certificates in code
- JWT secrets in source files
- OAuth client secrets in client-side code

**Injection Vectors (INJ-01 through INJ-05):**
- SQL query string concatenation (not parameterized)
- Command injection via shell exec with user input
- Path traversal patterns (../.. in file operations)
- Template injection (unescaped user data in templates)
- LDAP/NoSQL injection patterns

**XSS Vectors (XSS-01 through XSS-03):**
- innerHTML/dangerouslySetInnerHTML with user data
- Unescaped output in templates
- DOM manipulation with unsanitized input

**Data Exposure (DATA-01 through DATA-03):**
- Sensitive data in logs (passwords, tokens, PII)
- Error messages leaking internal details
- Verbose error responses to clients

**Access Control (ACL-01 through ACL-03):**
- Missing authentication checks on API routes
- Missing authorization (role/permission) checks
- Unscoped database queries (no user/tenant filter)

**API Security (API-01 through API-03):**
- Missing rate limiting on public endpoints
- Missing CORS configuration
- Missing input validation on API handlers

### Agent 2: Dependency Audit (Explore agent)
- Check for known vulnerabilities in dependencies
- For Node.js: parse `npm audit` output or check `package-lock.json`
- For Python: check `pip audit` or `safety check`
- For Go: check `go vuln`
- For Rust: check `cargo audit`
- Report dependency count, outdated count, vulnerability count

## Step 2: Synthesize Report

Combine both agent reports:

```
Security Audit Report
=====================

| Category | Ref IDs | Status | Findings |
|----------|---------|--------|----------|
| Hardcoded Secrets | AUTH-01..05 | CLEAN/WARN | Details |
| Injection Vectors | INJ-01..05 | CLEAN/WARN | Details |
| XSS Vectors | XSS-01..03 | CLEAN/WARN | Details |
| Data Exposure | DATA-01..03 | CLEAN/WARN | Details |
| Access Control | ACL-01..03 | CLEAN/WARN | Details |
| API Security | API-01..03 | CLEAN/WARN | Details |
| Dependencies | DEP-01 | CLEAN/WARN | Vuln count |

Score: X/100
Critical: N | High: N | Medium: N | Low: N
```

## Step 3: Recommendations

For each finding:
1. Severity (critical/high/medium/low)
2. File and line reference
3. Suggested fix
4. OWASP reference where applicable

Present findings sorted by severity. Offer to fix critical issues.
