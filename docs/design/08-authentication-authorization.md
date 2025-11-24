# Authentication & Authorization Design

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

Authentication and authorization strategy for Research Web Crawler, including user management, subscription tiers, permissions, and shared space access control.

## Authentication

### Sign In with Apple (Primary)

```swift
final class AuthenticationManager {
    func signInWithApple() async throws -> User {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorization = try await performSignIn(request)

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }

        // Create or fetch user
        let user = try await createOrFetchUser(
            appleId: appleIDCredential.user,
            email: appleIDCredential.email,
            name: appleIDCredential.fullName
        )

        // Save to keychain
        try saveUserCredentials(user)

        return user
    }

    func checkAuthStatus() async -> Bool {
        guard let userId = loadUserId() else { return false }

        let provider = ASAuthorizationAppleIDProvider()
        let state = try? await provider.credentialState(forUserID: userId)

        return state == .authorized
    }
}
```

### User Model

```swift
struct User: Codable, Identifiable {
    let id: String // Apple ID
    let email: String
    let name: String
    let created: Date
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiry: Date?

    var isSubscribed: Bool {
        guard let expiry = subscriptionExpiry else { return false }
        return expiry > Date()
    }
}
```

## Authorization

### Subscription Tiers

```swift
enum SubscriptionTier: String, Codable {
    case free
    case pro
    case academic
    case team

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .academic: return "Academic"
        case .team: return "Team"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .pro: return "$14.99/month"
        case .academic: return "$9.99/month"
        case .team: return "$49.99/month"
        }
    }

    var maxSources: Int {
        switch self {
        case .free: return 50
        case .pro: return .max
        case .academic: return .max
        case .team: return .max
        }
    }

    var aiSuggestionsEnabled: Bool {
        switch self {
        case .free: return false
        case .pro, .academic, .team: return true
        }
    }

    var collaborationEnabled: Bool {
        switch self {
        case .free, .pro, .academic: return false
        case .team: return true
        }
    }

    var cloudSyncEnabled: Bool {
        switch self {
        case .free: return false
        case .pro, .academic, .team: return true
        }
    }
}
```

### Feature Gate

```swift
final class FeatureGate {
    let user: User

    func checkAccess(to feature: Feature) throws {
        switch feature {
        case .addSource:
            if currentSourceCount >= user.subscriptionTier.maxSources {
                throw FeatureError.limitExceeded(
                    feature: "sources",
                    limit: user.subscriptionTier.maxSources,
                    upgrade: .pro
                )
            }

        case .aiSuggestions:
            guard user.subscriptionTier.aiSuggestionsEnabled else {
                throw FeatureError.requiresUpgrade(
                    feature: "AI Suggestions",
                    tier: .pro
                )
            }

        case .cloudSync:
            guard user.subscriptionTier.cloudSyncEnabled else {
                throw FeatureError.requiresUpgrade(
                    feature: "Cloud Sync",
                    tier: .pro
                )
            }

        case .collaboration:
            guard user.subscriptionTier.collaborationEnabled else {
                throw FeatureError.requiresUpgrade(
                    feature: "Collaboration",
                    tier: .team
                )
            }
        }
    }

    enum Feature {
        case addSource
        case aiSuggestions
        case cloudSync
        case collaboration
        case advancedExport
    }
}

enum FeatureError: Error {
    case limitExceeded(feature: String, limit: Int, upgrade: SubscriptionTier)
    case requiresUpgrade(feature: String, tier: SubscriptionTier)

    var message: String {
        switch self {
        case .limitExceeded(let feature, let limit, let tier):
            return "You've reached the limit of \(limit) \(feature). Upgrade to \(tier.displayName) for unlimited."
        case .requiresUpgrade(let feature, let tier):
            return "\(feature) requires \(tier.displayName). Upgrade to unlock."
        }
    }
}
```

## Shared Space Permissions

### Permission Model

```swift
enum Permission: String, Codable {
    case owner      // Full control
    case editor     // Add/edit/delete
    case commenter  // View + comment
    case viewer     // Read-only

    var canEdit: Bool {
        self == .owner || self == .editor
    }

    var canDelete: Bool {
        self == .owner
    }

    var canInvite: Bool {
        self == .owner
    }

    var canComment: Bool {
        self != .viewer
    }
}

struct SharedSpace {
    let projectId: UUID
    let ownerId: String
    var members: [Member]

    struct Member {
        let userId: String
        let email: String
        var permission: Permission
        let addedDate: Date
    }

    func checkPermission(_ userId: String, for action: Action) -> Bool {
        guard let member = members.first(where: { $0.userId == userId }) else {
            return false
        }

        switch action {
        case .view:
            return true // All members can view
        case .edit:
            return member.permission.canEdit
        case .delete:
            return member.permission.canDelete
        case .invite:
            return member.permission.canInvite
        case .comment:
            return member.permission.canComment
        }
    }

    enum Action {
        case view, edit, delete, invite, comment
    }
}
```

### Permission Checks

```swift
final class PermissionChecker {
    func checkAccess(user: String, project: Project, action: SharedSpace.Action) throws {
        // Personal project
        if project.ownerId == user {
            return // Owner has all permissions
        }

        // Shared project
        if project.isShared,
           let sharedSpace = loadSharedSpace(project.id) {
            guard sharedSpace.checkPermission(user, for: action) else {
                throw PermissionError.accessDenied
            }
        } else {
            throw PermissionError.notMember
        }
    }
}

enum PermissionError: Error {
    case accessDenied
    case notMember
    case ownerOnly

    var message: String {
        switch self {
        case .accessDenied:
            return "You don't have permission for this action."
        case .notMember:
            return "You're not a member of this project."
        case .ownerOnly:
            return "Only the owner can perform this action."
        }
    }
}
```

## In-App Purchases (StoreKit 2)

```swift
final class SubscriptionManager {
    func fetchProducts() async throws -> [Product] {
        let productIds = [
            "com.researchapp.pro.monthly",
            "com.researchapp.pro.yearly",
            "com.researchapp.academic.monthly",
            "com.researchapp.team.monthly"
        ]

        return try await Product.products(for: productIds)
    }

    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Update user tier
            await updateSubscription(transaction)

            await transaction.finish()
            return transaction

        case .userCancelled:
            throw PurchaseError.cancelled

        case .pending:
            throw PurchaseError.pending

        @unknown default:
            throw PurchaseError.unknown
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func updateSubscription(_ transaction: Transaction) async {
        // Map product ID to tier
        let tier: SubscriptionTier
        switch transaction.productID {
        case "com.researchapp.pro.monthly", "com.researchapp.pro.yearly":
            tier = .pro
        case "com.researchapp.academic.monthly":
            tier = .academic
        case "com.researchapp.team.monthly":
            tier = .team
        default:
            return
        }

        // Update user
        var user = AuthenticationManager.shared.currentUser!
        user.subscriptionTier = tier
        user.subscriptionExpiry = transaction.expirationDate

        try? await saveUser(user)
    }

    func restorePurchases() async throws {
        for await result in Transaction.currentEntitlements {
            let transaction = try checkVerified(result)
            await updateSubscription(transaction)
        }
    }
}
```

## Session Management

```swift
final class SessionManager {
    @AppStorage("userId") private var storedUserId: String?
    private var currentSession: Session?

    func startSession(for user: User) {
        let session = Session(
            userId: user.id,
            started: Date(),
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? ""
        )
        currentSession = session
        storedUserId = user.id
    }

    func endSession() {
        currentSession = nil
        storedUserId = nil
        clearUserData()
    }

    func validateSession() async -> Bool {
        guard let userId = storedUserId else { return false }
        return await AuthenticationManager.shared.checkAuthStatus()
    }
}

struct Session {
    let userId: String
    let started: Date
    let deviceId: String
}
```

## Security

### Keychain Storage

```swift
final class KeychainManager {
    func save(_ user: User) throws {
        let data = try JSONEncoder().encode(user)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "currentUser",
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete existing
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    func load() throws -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "currentUser",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return try JSONDecoder().decode(User.self, from: data)
    }
}
```

## References

- [Sign in with Apple](https://developer.apple.com/documentation/sign_in_with_apple)
- [StoreKit 2](https://developer.apple.com/documentation/storekit)
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
