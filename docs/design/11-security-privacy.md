# Security & Privacy Design

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

Security and privacy design for Research Web Crawler, covering data protection, user privacy, secure storage, and compliance with regulations.

## Security Principles

### 1. Defense in Depth
- Multiple layers of security
- No single point of failure
- Least privilege access

### 2. Privacy by Design
- Data minimization
- User control over data
- Transparency in data use

### 3. Secure by Default
- Encryption enabled by default
- Secure defaults for all settings
- No optional security

## Data Classification

### Sensitive Data
- User credentials (Apple ID)
- Subscription information
- Payment details (handled by Apple)
- **Storage**: Keychain only

### Private Data
- Research notes
- Source annotations
- Project names
- **Storage**: Encrypted local storage, optionally CloudKit

### Public Data (Potentially)
- Source metadata (title, author, DOI)
- Graph structure (if user shares publicly)
- **Storage**: Can be cached, shared

### Confidential Data
- API keys (LLM services)
- Server credentials
- **Storage**: Server-side only, environment variables

## Data Encryption

### At Rest

```swift
// File encryption using Data Protection API
func saveEncrypted(_ data: Data, to url: URL) throws {
    try data.write(to: url, options: [
        .completeFileProtectionUntilFirstUserAuthentication
    ])
}

// SwiftData encryption (automatic with Data Protection)
@Model
final class Source {
    // Automatically encrypted at rest
}

// PDF encryption
func encryptPDF(_ pdfURL: URL, password: String) throws -> URL {
    let document = PDFDocument(url: pdfURL)
    let options: [PDFDocumentWriteOption: Any] = [
        .userPasswordOption: password,
        .ownerPasswordOption: password
    ]

    let encryptedURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString + ".pdf")

    document?.write(to: encryptedURL, withOptions: options)
    return encryptedURL
}
```

### In Transit

```swift
// All network requests use HTTPS/TLS 1.3
let session = URLSession(configuration: .default)

// Certificate pinning for API
class PinnedSessionDelegate: NSObject, URLSessionDelegate {
    let pinnedCertificates: [SecCertificate]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Verify certificate
        if verifyCertificate(serverTrust, against: pinnedCertificates) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

### CloudKit Encryption

```swift
// CloudKit automatically encrypts data
// Use encrypted fields for sensitive data

@CloudKitRecord
final class SourceRecord: CKRecord {
    // Regular field (encrypted in transit and at rest)
    var title: String

    // Encrypted field (additionally encrypted, not queryable)
    @Encrypted var notes: String
}
```

## Authentication & Authorization

### Token Management

```swift
final class SecureTokenManager {
    func storeTokens(access: String, refresh: String) throws {
        // Store in Keychain
        let accessQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "accessToken",
            kSecValueData as String: access.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(accessQuery as CFDictionary, nil)

        let refreshQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "refreshToken",
            kSecValueData as String: refresh.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemAdd(refreshQuery as CFDictionary, nil)
    }

    func getAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "accessToken",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }
}
```

### Session Security

```swift
final class SessionSecurityManager {
    private var sessionTimeout: TimeInterval = 3600 // 1 hour
    private var lastActivity: Date = Date()

    func recordActivity() {
        lastActivity = Date()
    }

    func checkSessionTimeout() -> Bool {
        let elapsed = Date().timeIntervalSince(lastActivity)
        if elapsed > sessionTimeout {
            // Session expired
            logout()
            return true
        }
        return false
    }

    func logout() {
        // Clear tokens
        try? SecureTokenManager().clearTokens()

        // Clear sensitive data from memory
        // Navigate to login screen
    }
}
```

## Input Validation & Sanitization

### URL Validation

```swift
func validateURL(_ urlString: String) throws -> URL {
    // 1. Check format
    guard let url = URL(string: urlString) else {
        throw ValidationError.invalidURL
    }

    // 2. Check scheme (only https)
    guard url.scheme == "https" || url.scheme == "http" else {
        throw ValidationError.invalidScheme
    }

    // 3. Check for malicious patterns
    let maliciousPatterns = [
        "javascript:",
        "data:",
        "file:",
        "vbscript:"
    ]

    if maliciousPatterns.contains(where: { urlString.lowercased().contains($0) }) {
        throw ValidationError.maliciousURL
    }

    // 4. Check domain (optional: whitelist/blacklist)
    if isBlacklisted(url.host) {
        throw ValidationError.blockedDomain
    }

    return url
}
```

### Text Sanitization

```swift
func sanitizeHTML(_ html: String) -> String {
    // Remove script tags
    var sanitized = html.replacingOccurrences(
        of: "<script[^>]*>.*?</script>",
        with: "",
        options: .regularExpression
    )

    // Remove event handlers
    sanitized = sanitized.replacingOccurrences(
        of: "on\\w+=\"[^\"]*\"",
        with: "",
        options: .regularExpression
    )

    // Escape special characters
    sanitized = sanitized
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")

    return sanitized
}

func sanitizeUserInput(_ input: String, maxLength: Int = 1000) -> String {
    // Trim whitespace
    var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)

    // Limit length
    if sanitized.count > maxLength {
        sanitized = String(sanitized.prefix(maxLength))
    }

    // Remove control characters
    sanitized = sanitized.filter { !$0.isNewline && !$0.isControl || $0 == "\n" }

    return sanitized
}
```

## Vulnerability Prevention

### SQL Injection (N/A - Using SwiftData)
SwiftData prevents SQL injection by design.

### XSS (Cross-Site Scripting)

```swift
// When rendering user content in WKWebView
func renderUserContent(_ content: String) -> WKWebView {
    let webView = WKWebView()

    // Sanitize content
    let sanitized = sanitizeHTML(content)

    // Use Content Security Policy
    let html = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta http-equiv="Content-Security-Policy"
              content="default-src 'none'; style-src 'unsafe-inline';">
    </head>
    <body>\(sanitized)</body>
    </html>
    """

    webView.loadHTMLString(html, baseURL: nil)
    return webView
}
```

### Path Traversal

```swift
func secureFileAccess(_ filename: String) throws -> URL {
    // Validate filename
    guard !filename.contains(".."),
          !filename.contains("/"),
          !filename.isEmpty else {
        throw SecurityError.invalidFilename
    }

    // Construct safe path
    let documentsDir = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0]

    let fileURL = documentsDir.appendingPathComponent(filename)

    // Verify it's within documents directory
    guard fileURL.path.starts(with: documentsDir.path) else {
        throw SecurityError.pathTraversal
    }

    return fileURL
}
```

### Command Injection

```swift
// Never construct shell commands from user input
// If absolutely necessary, use whitelisting:

func safeCommand(_ userInput: String) throws -> String {
    let allowedCharacters = CharacterSet.alphanumerics
        .union(CharacterSet(charactersIn: "-_"))

    guard userInput.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
        throw SecurityError.invalidInput
    }

    return userInput
}
```

## Privacy Controls

### User Privacy Settings

```swift
struct PrivacySettings {
    var dataSharing: DataSharingLevel
    var analytics: Bool
    var crashReporting: Bool
    var aiSuggestions: Bool // Requires sending data to LLM

    enum DataSharingLevel {
        case none        // No data leaves device
        case minimal     // Only anonymous usage data
        case standard    // Include metadata for features
    }
}

final class PrivacyManager {
    var settings: PrivacySettings

    func canSendData(type: DataType) -> Bool {
        switch type {
        case .analytics:
            return settings.analytics

        case .crashReport:
            return settings.crashReporting

        case .sourceMetadata:
            // For AI suggestions
            return settings.aiSuggestions && settings.dataSharing != .none

        case .userNotes:
            // Never send without explicit consent
            return false
        }
    }
}
```

### Data Deletion

```swift
final class DataDeletionManager {
    func deleteAllUserData() async throws {
        // 1. Delete local database
        let modelContext = ModelContext(modelContainer)
        try modelContext.delete(model: Project.self)
        try modelContext.delete(model: Source.self)

        // 2. Delete files
        let documentsDir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        try FileManager.default.removeItem(at: documentsDir)

        // 3. Clear cache
        URLCache.shared.removeAllCachedResponses()

        // 4. Delete CloudKit records
        try await deleteCloudKitData()

        // 5. Clear Keychain
        try SecureTokenManager().clearTokens()

        // 6. Notify backend (if exists)
        try await apiClient.deleteAccount()
    }

    func deleteCloudKitData() async throws {
        let recordZone = CKRecordZone(zoneName: "ResearchWebCrawler")
        let database = CKContainer.default().privateCloudDatabase

        try await database.deleteRecordZone(withID: recordZone.zoneID)
    }
}
```

### Export User Data (GDPR)

```swift
func exportAllUserData() async throws -> URL {
    var exportData: [String: Any] = [:]

    // User profile
    exportData["user"] = [
        "id": user.id,
        "email": user.email,
        "subscriptionTier": user.subscriptionTier.rawValue
    ]

    // Projects
    let projects = try await fetchAllProjects()
    exportData["projects"] = projects.map { project in
        [
            "name": project.name,
            "sources": project.sources.map { source in
                [
                    "title": source.title,
                    "authors": source.authors,
                    "url": source.url?.absoluteString,
                    "notes": source.notes
                ]
            }
        ]
    }

    // Write to JSON
    let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    let exportURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("user_data_export.json")
    try jsonData.write(to: exportURL)

    return exportURL
}
```

## Compliance

### GDPR (General Data Protection Regulation)

**Requirements**:
- ✅ Right to access (export data)
- ✅ Right to deletion (delete account)
- ✅ Right to rectification (edit data)
- ✅ Data portability (export JSON)
- ✅ Consent for data processing (privacy settings)
- ✅ Data breach notification

### CCPA (California Consumer Privacy Act)

**Requirements**:
- ✅ Disclose data collection practices
- ✅ Right to know (what data is collected)
- ✅ Right to delete
- ✅ Right to opt-out of sale (we don't sell data)

### App Store Privacy Labels

**Data Collected**:
- Contact Info: Email (for account)
- User Content: Research notes, sources
- Identifiers: Apple ID
- Usage Data: Analytics (optional)

**Data Linked to User**: Yes (for account)
**Data Used to Track You**: No
**Data Not Collected**: Precise location, financial info, health data

## Security Auditing

### Logging

```swift
final class SecurityLogger {
    enum SecurityEvent {
        case loginAttempt(success: Bool, userId: String?)
        case dataExport(userId: String)
        case dataDelete(userId: String)
        case suspiciousActivity(description: String)
        case apiKeyAccess(service: String)
    }

    func log(_ event: SecurityEvent) {
        let logEntry: [String: Any]
        switch event {
        case .loginAttempt(let success, let userId):
            logEntry = [
                "event": "login_attempt",
                "success": success,
                "userId": userId ?? "unknown",
                "timestamp": Date().ISO8601Format()
            ]

        case .dataExport(let userId):
            logEntry = [
                "event": "data_export",
                "userId": userId,
                "timestamp": Date().ISO8601Format()
            ]

        case .suspiciousActivity(let description):
            logEntry = [
                "event": "suspicious_activity",
                "description": description,
                "timestamp": Date().ISO8601Format()
            ]
            // Alert security team

        default:
            return
        }

        // Write to secure log (server-side or encrypted local)
        writeToSecureLog(logEntry)
    }
}
```

### Penetration Testing Checklist

- [ ] Authentication bypass attempts
- [ ] Authorization escalation
- [ ] Input validation (XSS, injection)
- [ ] File upload vulnerabilities
- [ ] API rate limiting
- [ ] Token expiration and refresh
- [ ] Data encryption verification
- [ ] CloudKit permissions
- [ ] Network traffic analysis

## Incident Response

### Data Breach Response Plan

1. **Detection**: Monitor for unusual activity
2. **Containment**: Disable affected services
3. **Assessment**: Determine scope and impact
4. **Notification**: Inform affected users within 72 hours (GDPR)
5. **Remediation**: Fix vulnerability
6. **Recovery**: Restore services
7. **Post-mortem**: Document and improve

## Security Best Practices

### For Developers

1. **Never commit API keys** - Use environment variables
2. **Review dependencies** - Check for known vulnerabilities
3. **Use HTTPS everywhere** - No HTTP
4. **Validate all inputs** - Never trust user input
5. **Encrypt sensitive data** - Use Keychain
6. **Minimize permissions** - Request only what's needed
7. **Keep frameworks updated** - Patch vulnerabilities
8. **Test security** - Regular audits

### For Users (Documentation)

1. **Use strong passwords** - For device unlock
2. **Enable biometric authentication** - FaceID/TouchID
3. **Review privacy settings** - Control data sharing
4. **Update regularly** - Get security patches
5. **Be cautious with shared spaces** - Know who has access

## References

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Apple Security Guide](https://support.apple.com/guide/security/)
- [GDPR Compliance](https://gdpr.eu/)
- [CCPA Compliance](https://oag.ca.gov/privacy/ccpa)
