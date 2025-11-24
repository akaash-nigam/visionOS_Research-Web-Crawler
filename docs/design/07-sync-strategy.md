# Offline-First Sync Strategy

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Phase**: Post-MVP (Phase 2)

## Overview

This document outlines the synchronization strategy for Research Web Crawler using CloudKit, including conflict resolution, offline-first architecture, and real-time collaboration support.

**Note**: Sync is NOT in MVP. Local-only for MVP. CloudKit sync added in Phase 2.

## Sync Architecture

### Offline-First Principles

1. **Local-First**: All operations work locally without network
2. **Background Sync**: Sync happens automatically in background
3. **Conflict Resolution**: Automatic merging with user override
4. **Selective Sync**: User controls what syncs
5. **Bandwidth Aware**: Large files sync on WiFi only

### CloudKit Schema

```swift
// Record Types

// CKProject
@CloudKitRecord
final class ProjectRecord: CKRecord {
    static let recordType = "Project"

    var projectId: UUID
    var name: String
    var ownerId: String
    var isShared: Bool
    var modified: Date
    var graphData: CKAsset // JSON file
}

// CKSource
@CloudKitRecord
final class SourceRecord: CKRecord {
    static let recordType = "Source"

    var sourceId: UUID
    var projectId: CKReference
    var title: String
    var authors: [String]
    var type: String
    var url: String?
    var doi: String?
    var modified: Date
    // ... other metadata
}

// CKConnection
@CloudKitRecord
final class ConnectionRecord: CKRecord {
    static let recordType = "Connection"

    var connectionId: UUID
    var projectId: CKReference
    var fromSourceId: UUID
    var toSourceId: UUID
    var type: String
    var modified: Date
}
```

### Sync Manager

```swift
final class SyncManager {
    let container: CKContainer
    let privateDatabase: CKDatabase
    let sharedDatabase: CKDatabase

    var isSyncing: Bool = false
    var lastSyncDate: Date?

    func startSync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            // 1. Pull changes from CloudKit
            try await pullChanges()

            // 2. Push local changes to CloudKit
            try await pushChanges()

            lastSyncDate = Date()
        } catch {
            print("Sync error: \(error)")
        }
    }

    func pullChanges() async throws {
        // Fetch changes since last sync
        let zone = CKRecordZone(zoneName: "ResearchWebCrawler")
        let token = loadChangeToken()

        let changes = try await privateDatabase.recordZoneChanges(
            inZoneWith: zone.zoneID,
            since: token
        )

        // Apply changes to local database
        for record in changes.modified {
            try await applyRemoteChange(record)
        }

        for recordID in changes.deleted {
            try await deleteLocalRecord(recordID)
        }

        // Save new token
        saveChangeToken(changes.changeToken)
    }

    func pushChanges() async throws {
        // Find local changes since last sync
        let localChanges = try await fetchLocalChanges(since: lastSyncDate)

        // Upload to CloudKit
        for change in localChanges {
            let record = try createCKRecord(from: change)
            try await privateDatabase.save(record)
        }
    }
}
```

## Conflict Resolution

### Conflict Detection

```swift
struct Conflict {
    let localVersion: Source
    let remoteVersion: Source
    let field: String
    let conflictType: ConflictType

    enum ConflictType {
        case update // Both modified
        case delete // One deleted, one modified
    }
}

final class ConflictResolver {
    func detect(local: Source, remote: Source) -> [Conflict]? {
        var conflicts: [Conflict] = []

        // Compare modification dates
        if local.modified > remote.modified && remote.modified > lastSyncDate {
            // Concurrent modification
            if local.title != remote.title {
                conflicts.append(Conflict(
                    localVersion: local,
                    remoteVersion: remote,
                    field: "title",
                    conflictType: .update
                ))
            }
            // Check other fields...
        }

        return conflicts.isEmpty ? nil : conflicts
    }

    func resolve(_ conflict: Conflict, strategy: ResolutionStrategy) -> Source {
        switch strategy {
        case .useLocal:
            return conflict.localVersion

        case .useRemote:
            return conflict.remoteVersion

        case .useNewer:
            return conflict.localVersion.modified > conflict.remoteVersion.modified
                ? conflict.localVersion
                : conflict.remoteVersion

        case .merge:
            return mergeChanges(conflict.localVersion, conflict.remoteVersion)

        case .askUser:
            // Show conflict resolution UI
            fatalError("User resolution not implemented")
        }
    }

    private func mergeChanges(_ local: Source, _ remote: Source) -> Source {
        var merged = local

        // Field-by-field merge (newer wins)
        if remote.modified > local.modified {
            merged.title = remote.title
        }

        // Notes: Concatenate instead of overwrite
        if let localNotes = local.notes, let remoteNotes = remote.notes {
            merged.notes = """
            [Local]
            \(localNotes)

            [Remote]
            \(remoteNotes)
            """
        }

        return merged
    }
}

enum ResolutionStrategy {
    case useLocal
    case useRemote
    case useNewer
    case merge
    case askUser
}
```

### Operational Transform (for Real-Time Collab)

```swift
// For real-time collaboration (Phase 3)
struct Operation: Codable {
    let id: UUID
    let type: OperationType
    let sourceId: UUID
    let field: String
    let oldValue: String?
    let newValue: String?
    let timestamp: Date
    let userId: String

    enum OperationType: String, Codable {
        case insert, delete, update
    }
}

final class OperationTransformer {
    func transform(_ op1: Operation, against op2: Operation) -> Operation? {
        // Operational Transformation algorithm
        // Transform op1 assuming op2 has been applied
        // Used for concurrent editing
        return op1
    }

    func apply(_ operation: Operation, to source: Source) throws -> Source {
        var updated = source

        switch operation.type {
        case .update:
            // Apply update using key path
            if operation.field == "title" {
                updated.title = operation.newValue ?? ""
            }
            // ... other fields

        case .insert:
            // Insert operation
            break

        case .delete:
            // Delete operation
            break
        }

        return updated
    }
}
```

## Selective Sync

### Sync Configuration

```swift
struct SyncSettings {
    var syncEnabled: Bool = true
    var syncOnCellular: Bool = false
    var syncPDFs: Bool = false // PDFs are large
    var syncProjects: Set<UUID> = [] // Empty = all

    var autoSync: Bool = true
    var syncInterval: TimeInterval = 300 // 5 minutes
}

final class SelectiveSyncManager {
    var settings: SyncSettings

    func shouldSync(_ entity: SyncableEntity) -> Bool {
        guard settings.syncEnabled else { return false }

        // Check network conditions
        if !settings.syncOnCellular && !isOnWiFi() {
            return false
        }

        // Check entity type
        if entity is PDFFile && !settings.syncPDFs {
            return false
        }

        // Check project filter
        if !settings.syncProjects.isEmpty {
            if let projectId = entity.projectId,
               !settings.syncProjects.contains(projectId) {
                return false
            }
        }

        return true
    }
}
```

## Bandwidth Management

### Chunked Upload for Large Files

```swift
func uploadLargeFile(_ fileURL: URL) async throws {
    let chunkSize = 5 * 1024 * 1024 // 5MB chunks
    let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as! Int
    let chunkCount = (fileSize + chunkSize - 1) / chunkSize

    for i in 0..<chunkCount {
        let offset = i * chunkSize
        let length = min(chunkSize, fileSize - offset)

        let chunk = try readChunk(from: fileURL, offset: offset, length: length)
        try await uploadChunk(chunk, index: i, total: chunkCount)

        // Update progress
        let progress = Double(i + 1) / Double(chunkCount)
        notifyProgress(progress)
    }
}
```

### Compression

```swift
func compressGraphData(_ graph: Graph) throws -> Data {
    let encoder = JSONEncoder()
    let jsonData = try encoder.encode(graph)

    // Compress with zlib
    let compressed = try (jsonData as NSData).compressed(using: .zlib) as Data

    print("Original: \(jsonData.count) bytes")
    print("Compressed: \(compressed.count) bytes")
    print("Ratio: \(Double(compressed.count) / Double(jsonData.count))")

    return compressed
}
```

## Real-Time Collaboration (Phase 3)

### SharePlay Integration

```swift
final class CollaborationSession {
    let groupSession: GroupSession<ResearchActivity>

    func startCollaboration() async throws {
        // Start SharePlay session
        let activity = ResearchActivity(projectId: project.id)
        let session = try await activity.prepareForActivation()

        // Listen for participants
        for await participant in session.participants {
            handleParticipantJoined(participant)
        }
    }

    func broadcastOperation(_ operation: Operation) async {
        // Send to all participants
        try? await groupSession.send(operation)
    }

    func receiveOperations() async {
        for await operation in groupSession.operations {
            applyRemoteOperation(operation)
        }
    }
}
```

### WebSocket Alternative (if not using SharePlay)

```swift
final class WebSocketSync {
    var socket: URLSessionWebSocketTask

    func connect(projectId: UUID) {
        let url = URL(string: "wss://api.researchapp.com/sync/\(projectId)")!
        socket = URLSession.shared.webSocketTask(with: url)
        socket.resume()

        receiveMessages()
    }

    func sendOperation(_ operation: Operation) {
        let data = try! JSONEncoder().encode(operation)
        let message = URLSessionWebSocketTask.Message.data(data)
        socket.send(message) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
    }

    func receiveMessages() {
        socket.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessages() // Continue receiving
            case .failure(let error):
                print("Receive error: \(error)")
            }
        }
    }
}
```

## Testing Sync

### Sync Tests

```swift
func testBasicSync() async throws {
    // 1. Create local source
    let source = Source(title: "Test", type: .article, projectId: project.id, addedBy: "user1")
    try await localDB.save(source)

    // 2. Sync
    try await syncManager.startSync()

    // 3. Verify CloudKit has record
    let record = try await cloudKit.fetch(recordID: source.id)
    XCTAssertEqual(record["title"], "Test")
}

func testConflictResolution() async throws {
    // 1. Create source locally and remotely
    let localSource = Source(title: "Local", ...)
    let remoteSource = Source(title: "Remote", ...)

    // 2. Detect conflict
    let conflicts = conflictResolver.detect(local: localSource, remote: remoteSource)
    XCTAssertNotNil(conflicts)

    // 3. Resolve with "newer wins"
    let resolved = conflictResolver.resolve(conflicts![0], strategy: .useNewer)
    XCTAssertEqual(resolved.title, "Remote") // Assuming remote is newer
}
```

## Next Steps

1. Setup CloudKit schema
2. Implement basic push/pull sync
3. Add conflict detection
4. Implement conflict resolution strategies
5. Add sync settings UI
6. Test with multiple devices
7. Add real-time collaboration (Phase 3)

## References

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Operational Transformation](https://en.wikipedia.org/wiki/Operational_transformation)
- [CRDTs for Distributed Systems](https://crdt.tech/)
