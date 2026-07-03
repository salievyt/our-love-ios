# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Our Love seriously. If you believe you've found a security vulnerability, please report it responsibly.

### How to Report

1. **DO NOT** open a public GitHub issue
2. Email your findings to: **saliev.iakhebek@gmail.com**
3. Include a detailed description of the vulnerability
4. Include steps to reproduce the issue if possible
5. Include potential impact of the vulnerability

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within **48 hours**
- **Update**: We will provide a status update within **7 days**
- **Resolution**: We aim to resolve critical issues within **30 days**
- **Credit**: We will credit reporters in our security advisories (unless you prefer to remain anonymous)

### Scope

The following areas are in scope for security reports:

- Authentication and authorization (JWT tokens, Keychain storage)
- Data transmission (API endpoints, network requests)
- Data storage (local caching, sensitive data handling)
- Third-party dependencies
- Mobile-specific security (iOS Keychain, entitlements)

### Out of Scope

- Social engineering attacks
- Denial of service (DoS) attacks
- Physical security vulnerabilities
- Issues in dependencies (please report to the respective project)

### Security Best Practices

This project follows these security practices:

- **JWT tokens** stored securely in iOS Keychain
- **HTTPS-only** communication with API endpoints
- **Input validation** on all user-provided data
- **Regular dependency updates** via GitHub Actions
- **Code signing** for all production builds
- **No hardcoded secrets** or API keys in the codebase

### Security Features

| Feature | Implementation |
|---------|---------------|
| Authentication | JWT (access + refresh tokens) |
| Token Storage | iOS Keychain (encrypted) |
| Network | HTTPS/TLS 1.2+ |
| Data | Encrypted at rest via Keychain |
| API | Bearer token authentication |

## Contact

For any security-related questions, please contact:

- **Email**: saliev.iakhebek@gmail.com
- **GitHub**: [@salievyt](https://github.com/salievyt)
