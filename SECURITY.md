# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The Majdoor Mitra team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to:
- **Email:** akaash.nigam@example.com (update with your actual email)

Include the following information:
- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

After you submit a report, you can expect:

1. **Acknowledgment:** We'll acknowledge receipt of your vulnerability report within 48 hours.
2. **Investigation:** We'll investigate the issue and determine its impact and severity.
3. **Updates:** We'll keep you informed about our progress fixing the vulnerability.
4. **Resolution:** Once fixed, we'll notify you and publicly disclose the issue (with credit to you, if desired).

### Preferred Languages

We prefer all communications to be in English.

## Security Best Practices for Contributors

### Code Review
- All code changes require review before merging
- Security-sensitive changes require additional scrutiny
- Use GitHub's code scanning alerts

### Dependency Management
- Keep dependencies up to date
- Review Dependabot alerts promptly
- Audit third-party libraries before adding them

### Sensitive Data
- Never commit API keys, passwords, or secrets
- Use environment variables or secure vaults for sensitive configuration
- Review `.gitignore` to ensure sensitive files are excluded

### Authentication & Authorization
- Implement proper authentication for all API endpoints
- Use secure token storage (KeyStore on Android)
- Validate all user inputs
- Implement proper session management

### Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all network communication
- Implement certificate pinning for critical endpoints
- Follow Android security best practices

### Testing
- Write security-focused test cases
- Test authentication and authorization flows
- Validate input sanitization
- Test encryption implementations

## Security Features in This Project

### Current Implementations

1. **Secure Storage**
   - `SecureStorageManager` uses Android KeyStore
   - Encryption for sensitive local data

2. **Network Security**
   - HTTPS enforced
   - Network security config
   - Certificate pinning ready

3. **Authentication**
   - OTP-based authentication
   - Secure token management
   - Session timeout handling

4. **Input Validation**
   - Comprehensive validators in `Validators.kt`
   - Entity validation in `EntityValidators.kt`

5. **ProGuard/R8**
   - Code obfuscation enabled for release builds
   - Configured in `app/proguard-rules.pro`

### Automated Security

- **CodeQL Analysis:** Runs on every push and weekly
- **Dependabot:** Monitors dependencies for vulnerabilities
- **GitHub Secret Scanning:** Prevents accidental secret commits

## Known Security Considerations

### In Development
- API endpoints are currently placeholders
- Backend authentication not yet implemented
- Production SSL certificates needed

### Before Production
- [ ] Configure production API endpoints
- [ ] Set up proper certificate pinning
- [ ] Implement rate limiting
- [ ] Add comprehensive logging and monitoring
- [ ] Conduct security audit
- [ ] Penetration testing
- [ ] Set up secure key management for releases

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release new security fix versions as soon as possible

## Comments on This Policy

If you have suggestions on how this process could be improved, please submit a pull request or open an issue.

## Attribution

We appreciate the security research community and will acknowledge security researchers who responsibly disclose vulnerabilities to us.
