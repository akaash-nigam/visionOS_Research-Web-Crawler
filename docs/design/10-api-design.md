# API Design Document

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Phase**: Future (Backend Optional)

## Overview

This document outlines potential backend API design for Research Web Crawler. **Note**: MVP is fully client-side with no custom backend. This design is for future scalability.

## API Architecture (Future)

### When to Add Backend

Consider backend when:
1. **Web scraping proxy** - Avoid client IP rate limits
2. **API key management** - Hide LLM API keys from client
3. **Analytics** - Track usage and metrics
4. **Team collaboration** - Real-time sync beyond CloudKit
5. **Content caching** - Shared cache across users

### Technology Stack

- **API Gateway**: AWS API Gateway or Cloudflare Workers
- **Backend**: Swift Vapor or Node.js
- **Database**: PostgreSQL (metadata), Redis (cache)
- **Storage**: S3 (PDFs, assets)
- **Queue**: Redis Queue (async jobs)

## REST API Design

### Base URL
```
https://api.researchapp.com/v1
```

### Authentication

All endpoints require Bearer token (JWT):
```http
Authorization: Bearer <token>
```

### Endpoints

#### Authentication

```http
POST /auth/signin
Content-Type: application/json

{
  "appleIdToken": "string"
}

Response 200:
{
  "userId": "string",
  "accessToken": "string",
  "refreshToken": "string",
  "subscriptionTier": "pro"
}
```

```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "string"
}

Response 200:
{
  "accessToken": "string"
}
```

#### Projects

```http
GET /projects
Response 200:
{
  "projects": [
    {
      "id": "uuid",
      "name": "string",
      "sourceCount": 0,
      "modified": "ISO8601"
    }
  ]
}
```

```http
GET /projects/:id
Response 200:
{
  "id": "uuid",
  "name": "string",
  "sources": [...],
  "connections": [...],
  "modified": "ISO8601"
}
```

```http
POST /projects
Content-Type: application/json

{
  "name": "string"
}

Response 201:
{
  "id": "uuid",
  "name": "string",
  "created": "ISO8601"
}
```

#### Sources

```http
POST /projects/:projectId/sources
Content-Type: application/json

{
  "url": "string"
}

Response 201:
{
  "id": "uuid",
  "title": "string",
  "authors": ["string"],
  "type": "article",
  "metadata": {...}
}
```

```http
GET /projects/:projectId/sources/:sourceId
Response 200:
{
  "id": "uuid",
  "title": "string",
  ...
}
```

#### Web Scraping Proxy

```http
POST /scrape
Content-Type: application/json

{
  "url": "string"
}

Response 200:
{
  "title": "string",
  "authors": ["string"],
  "content": "string",
  "metadata": {...}
}

Response 429: Rate limit exceeded
Response 403: Site blocks scraping
```

#### AI Suggestions

```http
POST /projects/:projectId/suggestions
Content-Type: application/json

{
  "types": ["missingLinks", "gaps"]
}

Response 200:
{
  "suggestions": [
    {
      "type": "missingConnection",
      "confidence": 0.85,
      "fromSourceId": "uuid",
      "toSourceId": "uuid",
      "reasoning": "string"
    }
  ]
}
```

#### Metadata Lookup

```http
GET /metadata/doi/:doi
Response 200:
{
  "title": "string",
  "authors": ["string"],
  "journal": "string",
  ...
}
```

```http
GET /metadata/isbn/:isbn
Response 200:
{
  "title": "string",
  "authors": ["string"],
  "publisher": "string",
  ...
}
```

### Error Responses

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Try again in 60 seconds.",
    "retryAfter": 60
  }
}
```

Error Codes:
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `RATE_LIMIT_EXCEEDED` (429)
- `INTERNAL_ERROR` (500)

## GraphQL Alternative

```graphql
type Query {
  me: User!
  project(id: ID!): Project
  projects: [Project!]!
  source(id: ID!): Source
}

type Mutation {
  createProject(input: CreateProjectInput!): Project!
  addSource(projectId: ID!, url: String!): Source!
  createConnection(input: CreateConnectionInput!): Connection!
  generateSuggestions(projectId: ID!): [Suggestion!]!
}

type Subscription {
  projectUpdated(projectId: ID!): ProjectUpdate!
}

type User {
  id: ID!
  email: String!
  subscriptionTier: SubscriptionTier!
  projects: [Project!]!
}

type Project {
  id: ID!
  name: String!
  sources: [Source!]!
  connections: [Connection!]!
  modified: DateTime!
}

type Source {
  id: ID!
  title: String!
  authors: [String!]!
  type: SourceType!
  url: String
  doi: String
  connections: [Connection!]!
}

type Connection {
  id: ID!
  from: Source!
  to: Source!
  type: ConnectionType!
  annotation: String
}

type Suggestion {
  type: SuggestionType!
  confidence: Float!
  reasoning: String!
}

enum SubscriptionTier {
  FREE
  PRO
  ACADEMIC
  TEAM
}

enum SourceType {
  ARTICLE
  ACADEMIC_PAPER
  BOOK
  WEBSITE
}

enum ConnectionType {
  CITES
  SUPPORTS
  CONTRADICTS
  RELATED
}

enum SuggestionType {
  MISSING_CONNECTION
  GAP_IDENTIFICATION
  CONTRADICTION
}
```

## Rate Limiting

```swift
// Server-side rate limiter
final class RateLimiter {
    func checkLimit(userId: String, endpoint: String) -> RateLimitResult {
        let limits: [String: RateLimit] = [
            "/scrape": RateLimit(requests: 100, window: 3600), // 100/hour
            "/suggestions": RateLimit(requests: 50, window: 86400), // 50/day
            "/projects": RateLimit(requests: 1000, window: 3600) // 1000/hour
        ]

        guard let limit = limits[endpoint] else {
            return .allowed
        }

        let count = redis.get("rate:\(userId):\(endpoint)")
        if count >= limit.requests {
            return .exceeded(retryAfter: limit.window)
        }

        redis.incr("rate:\(userId):\(endpoint)")
        redis.expire("rate:\(userId):\(endpoint)", limit.window)

        return .allowed
    }
}

enum RateLimitResult {
    case allowed
    case exceeded(retryAfter: Int)
}

struct RateLimit {
    let requests: Int
    let window: TimeInterval
}
```

## Caching Strategy

### Redis Cache

```swift
// Cache scraped content
func scrapeWithCache(url: URL) async throws -> ScrapedContent {
    let cacheKey = "scrape:\(url.absoluteString.hash)"

    // Check cache
    if let cached = try? await redis.get(cacheKey, as: ScrapedContent.self) {
        return cached
    }

    // Scrape
    let content = try await scraper.scrape(url)

    // Cache for 7 days
    try await redis.set(cacheKey, to: content, expiresIn: 7 * 24 * 3600)

    return content
}
```

## WebSocket API (Real-Time Collaboration)

```swift
// WebSocket connection
ws://api.researchapp.com/v1/projects/:projectId/sync

// Client -> Server
{
  "type": "operation",
  "operation": {
    "id": "uuid",
    "type": "addSource",
    "data": {...}
  }
}

// Server -> Client
{
  "type": "operation",
  "userId": "string",
  "operation": {...}
}

// Server -> All Clients (broadcast)
{
  "type": "participantJoined",
  "userId": "string",
  "userName": "string"
}
```

## Security

### API Key Management

```swift
// Client stores only refresh token in Keychain
// Access tokens are short-lived (1 hour)
// API keys for LLM services stay server-side

struct APIKeyManager {
    func getOpenAIKey() -> String {
        // Stored securely on server, not in client
        return env("OPENAI_API_KEY")
    }
}
```

### Request Validation

```swift
func validateRequest(_ request: Request) throws {
    // Check content length
    guard request.body.contentLength ?? 0 < 10_000_000 else {
        throw APIError.payloadTooLarge
    }

    // Check user agent
    guard request.headers["User-Agent"].first?.contains("ResearchApp") == true else {
        throw APIError.invalidClient
    }

    // Verify JWT
    let jwt = try request.jwt.verify(as: UserToken.self)

    // Check subscription tier
    let user = try await db.users.find(jwt.userId)
    try featureGate.checkAccess(user: user, endpoint: request.url.path)
}
```

## Analytics & Telemetry

```swift
struct AnalyticsEvent {
    let userId: String
    let event: String
    let properties: [String: Any]
    let timestamp: Date
}

// Track usage
func trackEvent(_ event: AnalyticsEvent) {
    // Send to analytics service (PostHog, Amplitude, etc.)
    analytics.track(
        userId: event.userId,
        event: event.event,
        properties: event.properties
    )
}

// Example events
trackEvent(AnalyticsEvent(
    userId: "user123",
    event: "source_added",
    properties: ["type": "article", "method": "url"],
    timestamp: Date()
))
```

## Monitoring

### Health Check

```http
GET /health
Response 200:
{
  "status": "ok",
  "version": "1.0.0",
  "services": {
    "database": "ok",
    "redis": "ok",
    "openai": "ok"
  }
}
```

### Metrics

```swift
// Prometheus metrics
// - request_count{endpoint, method, status}
// - request_duration{endpoint}
// - active_users
// - scraping_jobs_queued
// - llm_api_cost
```

## Client SDK

```swift
final class ResearchAPIClient {
    let baseURL: URL
    let session: URLSession

    func fetchProjects() async throws -> [Project] {
        let url = baseURL.appendingPathComponent("/projects")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([Project].self, from: data)
    }

    func scrapeURL(_ url: URL) async throws -> ScrapedContent {
        let endpoint = baseURL.appendingPathComponent("/scrape")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["url": url.absoluteString])

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(ScrapedContent.self, from: data)
    }
}
```

## References

- [REST API Design Best Practices](https://restfulapi.net/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)
- [API Security](https://owasp.org/www-project-api-security/)
