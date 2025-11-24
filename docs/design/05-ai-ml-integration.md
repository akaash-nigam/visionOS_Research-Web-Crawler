# AI/ML Integration Design

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Phase**: Post-MVP (Phase 2)

## Overview

This document outlines the AI/ML integration strategy for Research Web Crawler, including LLM provider selection, suggestion algorithms, prompt engineering, cost management, and privacy considerations.

**Note**: AI features are NOT included in MVP. This is designed for Phase 2 (Months 4-6).

## AI Feature Overview

### Core AI Capabilities

1. **Missing Link Detection** - Identify connections between unconnected sources
2. **Gap Identification** - Find missing topics or sources in research
3. **Contradiction Detection** - Highlight conflicting sources
4. **Source Recommendations** - Suggest new sources to add
5. **Bridge Concepts** - Find connections between disconnected clusters
6. **Semantic Search** - Find similar sources by meaning, not just keywords
7. **Auto-Summarization** - Generate summaries of sources

## LLM Provider Architecture

### Provider Selection Strategy

```swift
protocol LLMProvider {
    func generateCompletion(prompt: String, model: String) async throws -> String
    func generateEmbedding(text: String) async throws -> [Float]
    func estimateCost(prompt: String, model: String) -> Double
}

final class OpenAIProvider: LLMProvider {
    let apiKey: String
    let baseURL = "https://api.openai.com/v1"

    func generateCompletion(prompt: String, model: String = "gpt-4-turbo") async throws -> String {
        // Implementation
    }

    func generateEmbedding(text: String) async throws -> [Float] {
        // text-embedding-3-large
    }
}

final class AnthropicProvider: LLMProvider {
    let apiKey: String
    let baseURL = "https://api.anthropic.com/v1"

    func generateCompletion(prompt: String, model: String = "claude-sonnet-4") async throws -> String {
        // Implementation
    }

    func generateEmbedding(text: String) async throws -> [Float] {
        // Use OpenAI or local model for embeddings
    }
}

final class LLMService {
    private var primaryProvider: LLMProvider
    private var fallbackProvider: LLMProvider?

    init(primary: LLMProvider, fallback: LLMProvider? = nil) {
        self.primaryProvider = primary
        self.fallbackProvider = fallback
    }

    func complete(prompt: String, model: String) async throws -> String {
        do {
            return try await primaryProvider.generateCompletion(prompt: prompt, model: model)
        } catch {
            if let fallback = fallbackProvider {
                return try await fallback.generateCompletion(prompt: prompt, model: model)
            }
            throw error
        }
    }
}
```

### Model Selection

| Use Case | Model | Cost | Reasoning |
|----------|-------|------|-----------|
| Missing Links | GPT-4-turbo | $10/1M tokens | Complex reasoning |
| Summarization | GPT-4-mini | $0.15/1M tokens | Cost-effective |
| Embeddings | text-embedding-3-large | $0.13/1M tokens | Best quality |
| Quick suggestions | Claude Haiku | $0.25/1M tokens | Fast, cheap |

## AI Suggestion System

### Suggestion Pipeline

```swift
final class AISuggestionEngine {
    let llmService: LLMService
    let embeddingService: EmbeddingService
    let graphAnalyzer: GraphAnalyzer

    func generateSuggestions(for project: Project) async throws -> [AISuggestion] {
        var suggestions: [AISuggestion] = []

        // 1. Analyze graph structure
        let analysis = await graphAnalyzer.analyze(project.graph)

        // 2. Missing links (connected sources with similar content)
        let missingLinks = try await detectMissingLinks(analysis)
        suggestions.append(contentsOf: missingLinks)

        // 3. Gap identification (topics not covered)
        let gaps = try await identifyGaps(analysis)
        suggestions.append(contentsOf: gaps)

        // 4. Contradictions (conflicting sources)
        let contradictions = try await detectContradictions(analysis)
        suggestions.append(contentsOf: contradictions)

        // 5. Bridge concepts (connect clusters)
        let bridges = try await findBridgeConcepts(analysis)
        suggestions.append(contentsOf: bridges)

        // 6. Source recommendations
        let recommendations = try await recommendSources(analysis)
        suggestions.append(contentsOf: recommendations)

        // Rank by confidence and relevance
        return suggestions.sorted { $0.confidence > $1.confidence }
    }
}
```

### 1. Missing Link Detection

```swift
func detectMissingLinks(_ analysis: GraphAnalysis) async throws -> [AISuggestion] {
    var suggestions: [AISuggestion] = []

    // Find pairs of unconnected nodes with high semantic similarity
    let unconnectedPairs = analysis.unconnectedNodePairs

    for pair in unconnectedPairs {
        let source1 = await getSource(pair.node1)
        let source2 = await getSource(pair.node2)

        // Compare embeddings
        let similarity = cosineSimilarity(
            source1.embeddingVector,
            source2.embeddingVector
        )

        if similarity > 0.75 {
            // High similarity, ask LLM for relationship
            let prompt = """
            Analyze these two research sources and determine if they should be connected:

            Source 1: "\(source1.title)" by \(source1.authors.joined(separator: ", "))
            Abstract: \(source1.abstract ?? "N/A")

            Source 2: "\(source2.title)" by \(source2.authors.joined(separator: ", "))
            Abstract: \(source2.abstract ?? "N/A")

            Are these sources related? If yes, what is the relationship type?
            Options: cites, supports, contradicts, related, extends

            Respond in JSON:
            {
              "related": true/false,
              "relationship": "type",
              "confidence": 0.0-1.0,
              "reasoning": "explanation"
            }
            """

            let response = try await llmService.complete(prompt: prompt, model: "gpt-4-turbo")
            let result = try JSONDecoder().decode(LinkSuggestion.self, from: response.data(using: .utf8)!)

            if result.related {
                let suggestion = AISuggestion(
                    projectId: analysis.projectId,
                    type: .missingConnection,
                    title: "Connect: \(source1.title) → \(source2.title)",
                    description: result.reasoning,
                    confidence: result.confidence
                )
                suggestion.suggestedConnectionFrom = source1.id
                suggestion.suggestedConnectionTo = source2.id
                suggestion.suggestedConnectionType = ConnectionType(rawValue: result.relationship)

                suggestions.append(suggestion)
            }
        }
    }

    return suggestions
}
```

### 2. Gap Identification

```swift
func identifyGaps(_ analysis: GraphAnalysis) async throws -> [AISuggestion] {
    // Extract topics from all sources
    let allTopics = analysis.sources.flatMap { $0.topicClusters }
    let topicFrequency = Dictionary(grouping: allTopics) { $0 }

    // Prepare context for LLM
    let sourceTitles = analysis.sources.map { "- \($0.title)" }.joined(separator: "\n")
    let mainTopics = topicFrequency.sorted { $0.value.count > $1.value.count }
        .prefix(10)
        .map { $0.key }
        .joined(separator: ", ")

    let prompt = """
    Analyze this research project and identify gaps in the literature coverage:

    Project: \(analysis.projectName)
    Number of sources: \(analysis.sources.count)

    Main topics covered: \(mainTopics)

    Sources:
    \(sourceTitles)

    What important topics, perspectives, or types of sources are missing?
    Consider: different methodologies, opposing viewpoints, recent developments, foundational works.

    Respond in JSON array format:
    [
      {
        "gap_type": "methodology/viewpoint/topic/foundational",
        "description": "what's missing",
        "importance": "high/medium/low",
        "suggested_search": "search query"
      }
    ]
    """

    let response = try await llmService.complete(prompt: prompt, model: "gpt-4-turbo")
    let gaps = try JSONDecoder().decode([GapSuggestion].self, from: response.data(using: .utf8)!)

    return gaps.map { gap in
        AISuggestion(
            projectId: analysis.projectId,
            type: .gapIdentification,
            title: "Missing: \(gap.description)",
            description: "Importance: \(gap.importance). Try searching: \(gap.suggested_search)",
            confidence: gap.importance == "high" ? 0.9 : 0.7
        )
    }
}
```

### 3. Contradiction Detection

```swift
func detectContradictions(_ analysis: GraphAnalysis) async throws -> [AISuggestion] {
    var suggestions: [AISuggestion] = []

    // Find sources with conflicting claims (connected with "contradicts" or high semantic similarity)
    let potentialConflicts = analysis.sources.combinations(ofCount: 2)
        .filter { pair in
            let (s1, s2) = (pair[0], pair[1])
            return cosineSimilarity(s1.embeddingVector, s2.embeddingVector) > 0.7
        }

    for pair in potentialConflicts.prefix(10) { // Limit to avoid excessive API calls
        let source1 = pair[0]
        let source2 = pair[1]

        let prompt = """
        Compare these two research sources and identify if they present contradictory claims:

        Source 1: "\(source1.title)"
        Key claims: \(source1.abstract ?? "")

        Source 2: "\(source2.title)"
        Key claims: \(source2.abstract ?? "")

        Do these sources contradict each other? If yes, explain the contradiction.

        Respond in JSON:
        {
          "contradicts": true/false,
          "contradiction_summary": "explanation",
          "severity": "major/minor",
          "confidence": 0.0-1.0
        }
        """

        let response = try await llmService.complete(prompt: prompt, model: "gpt-4-turbo")
        let result = try JSONDecoder().decode(ContradictionResult.self, from: response.data(using: .utf8)!)

        if result.contradicts {
            let suggestion = AISuggestion(
                projectId: analysis.projectId,
                type: .contradiction,
                title: "⚠️ Potential Contradiction Detected",
                description: result.contradiction_summary,
                reasoning: "Severity: \(result.severity)",
                confidence: result.confidence
            )
            suggestion.suggestedSourceIds = [source1.id, source2.id]

            suggestions.append(suggestion)
        }
    }

    return suggestions
}
```

### 4. Source Recommendations

```swift
func recommendSources(_ analysis: GraphAnalysis) async throws -> [AISuggestion] {
    // Use web search + LLM to find relevant sources

    let mainTopics = analysis.topTopics.prefix(5).joined(separator: ", ")

    let prompt = """
    Based on this research project, recommend 5 additional academic sources:

    Project: \(analysis.projectName)
    Topics: \(mainTopics)
    Current sources: \(analysis.sources.count)

    Existing sources:
    \(analysis.sources.map { "- \($0.title) (\($0.publicationDate?.year ?? ""))" }.joined(separator: "\n"))

    Recommend highly-cited, relevant academic sources that would strengthen this research.
    Include diverse perspectives and recent publications.

    Respond in JSON array:
    [
      {
        "title": "Paper title",
        "authors": ["Author 1", "Author 2"],
        "year": 2023,
        "doi": "10.xxxx/xxxxx",
        "relevance": "why this is relevant",
        "confidence": 0.0-1.0
      }
    ]
    """

    let response = try await llmService.complete(prompt: prompt, model: "gpt-4-turbo")
    let recommendations = try JSONDecoder().decode([SourceRecommendation].self,
                                                   from: response.data(using: .utf8)!)

    return recommendations.map { rec in
        let suggestion = AISuggestion(
            projectId: analysis.projectId,
            type: .missingSource,
            title: "Add: \(rec.title)",
            description: rec.relevance,
            confidence: rec.confidence
        )
        // Store DOI for easy addition
        suggestion.suggestedURL = URL(string: "https://doi.org/\(rec.doi)")

        return suggestion
    }
}
```

## Embedding & Semantic Search

### Embedding Generation

```swift
final class EmbeddingService {
    let llmProvider: LLMProvider
    let cache: EmbeddingCache

    func generateEmbedding(for source: Source) async throws -> [Float] {
        // Check cache first
        if let cached = cache.get(source.id) {
            return cached
        }

        // Combine title, abstract, key phrases
        let text = """
        \(source.title)
        \(source.abstract ?? "")
        \(source.keyPhrases.joined(separator: ", "))
        """.trimmingCharacters(in: .whitespacesAndNewlines)

        let embedding = try await llmProvider.generateEmbedding(text: text)

        // Cache
        cache.set(source.id, embedding: embedding)

        return embedding
    }

    func batchGenerateEmbeddings(for sources: [Source]) async throws -> [UUID: [Float]] {
        // Process in batches of 100
        var embeddings: [UUID: [Float]] = [:]

        for batch in sources.chunked(into: 100) {
            try await withThrowingTaskGroup(of: (UUID, [Float]).self) { group in
                for source in batch {
                    group.addTask {
                        let embedding = try await self.generateEmbedding(for: source)
                        return (source.id, embedding)
                    }
                }

                for try await (id, embedding) in group {
                    embeddings[id] = embedding
                }
            }
        }

        return embeddings
    }
}
```

### Semantic Search

```swift
final class SemanticSearchEngine {
    let embeddingService: EmbeddingService

    func search(query: String, in sources: [Source], topK: Int = 10) async throws -> [SearchResult] {
        // Generate query embedding
        let queryEmbedding = try await embeddingService.llmProvider.generateEmbedding(text: query)

        // Calculate similarity with all sources
        var results: [SearchResult] = []

        for source in sources {
            guard let sourceEmbedding = source.embeddingVector else { continue }

            let similarity = cosineSimilarity(queryEmbedding, sourceEmbedding)

            results.append(SearchResult(
                source: source,
                similarity: similarity,
                snippet: extractRelevantSnippet(from: source, query: query)
            ))
        }

        // Sort by similarity and return top K
        return results.sorted { $0.similarity > $1.similarity }.prefix(topK).map { $0 }
    }
}
```

## Prompt Engineering

### Prompt Templates

```swift
struct PromptTemplate {
    let system: String
    let user: String

    static let missingLink = PromptTemplate(
        system: """
        You are a research assistant helping identify relationships between academic sources.
        Analyze source abstracts and titles to determine if they should be connected.
        Consider: citations, supporting evidence, contradictions, shared topics.
        """,
        user: """
        Source 1: {title1}
        Abstract: {abstract1}

        Source 2: {title2}
        Abstract: {abstract2}

        Question: Should these sources be connected? If yes, what relationship?
        Response format: JSON
        """
    )

    static let gapIdentification = PromptTemplate(
        system: """
        You are a research advisor reviewing literature coverage.
        Identify gaps: missing perspectives, methodologies, foundational works, recent developments.
        Be specific and actionable in your recommendations.
        """,
        user: """
        Project: {project_name}
        Topics: {topics}
        Sources: {source_list}

        Question: What important sources or perspectives are missing?
        Response format: JSON array
        """
    )

    func render(variables: [String: String]) -> String {
        var rendered = user
        for (key, value) in variables {
            rendered = rendered.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return rendered
    }
}
```

## Cost Management

### Cost Tracking

```swift
final class AIcostTracker {
    private var totalCost: Double = 0
    private var costByUser: [String: Double] = [:]
    private var costByFeature: [SuggestionType: Double] = [:]

    func trackRequest(userId: String, feature: SuggestionType,
                      inputTokens: Int, outputTokens: Int, model: String) {
        let cost = calculateCost(
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            model: model
        )

        totalCost += cost
        costByUser[userId, default: 0] += cost
        costByFeature[feature, default: 0] += cost
    }

    func calculateCost(inputTokens: Int, outputTokens: Int, model: String) -> Double {
        let rates = ModelPricing.rates[model] ?? (input: 0, output: 0)
        return (Double(inputTokens) * rates.input + Double(outputTokens) * rates.output) / 1_000_000
    }

    func checkBudget(userId: String, tier: SubscriptionTier) -> Bool {
        let userCost = costByUser[userId] ?? 0
        let budget = tier.aiSuggestionBudget

        return userCost < budget
    }
}

struct ModelPricing {
    static let rates: [String: (input: Double, output: Double)] = [
        "gpt-4-turbo": (input: 10.0, output: 30.0),
        "gpt-4-mini": (input: 0.15, output: 0.6),
        "claude-sonnet-4": (input: 3.0, output: 15.0),
        "text-embedding-3-large": (input: 0.13, output: 0)
    ]
}
```

### Rate Limiting

```swift
final class AIRateLimiter {
    private var requestCounts: [String: Int] = [:]
    private var lastReset: [String: Date] = [:]

    func checkLimit(userId: String, tier: SubscriptionTier) -> Bool {
        let now = Date()
        let lastReset = self.lastReset[userId] ?? now
        let hoursSinceReset = now.timeIntervalSince(lastReset) / 3600

        // Reset counter every 24 hours
        if hoursSinceReset >= 24 {
            requestCounts[userId] = 0
            self.lastReset[userId] = now
        }

        let count = requestCounts[userId] ?? 0
        let limit = tier.aiSuggestionsPerDay

        if count >= limit {
            return false // Limit exceeded
        }

        requestCounts[userId] = count + 1
        return true
    }
}

extension SubscriptionTier {
    var aiSuggestionsPerDay: Int {
        switch self {
        case .free: return 10
        case .pro: return 1000
        case .academic: return 500
        case .team: return 5000
        }
    }

    var aiSuggestionBudget: Double {
        switch self {
        case .free: return 0.50 // $0.50/day
        case .pro: return 10.0  // $10/day
        case .academic: return 5.0
        case .team: return 50.0
        }
    }
}
```

## Privacy & User Consent

### Consent Management

```swift
final class AIConsentManager {
    @AppStorage("ai_suggestions_enabled") var isEnabled: Bool = false
    @AppStorage("ai_data_sharing_consent") var hasConsent: Bool = false

    func requestConsent() async -> Bool {
        // Show consent dialog
        let consent = await showConsentDialog()
        hasConsent = consent
        isEnabled = consent
        return consent
    }

    func showConsentDialog() async -> Bool {
        // UI explaining:
        // - What data is sent (titles, abstracts, metadata)
        // - What data is NOT sent (PDFs, notes, personal info)
        // - Which API (OpenAI/Anthropic)
        // - Purpose (suggestions)
        // - User can revoke anytime
        return true // User's decision
    }

    func isAllowedToSendData(for source: Source) -> Bool {
        guard hasConsent else { return false }

        // Don't send sensitive data
        if source.notes?.contains("private") == true {
            return false
        }

        return true
    }
}
```

### Data Minimization

```swift
struct MinimalSourceData: Codable {
    let title: String
    let authors: [String]
    let abstract: String?
    let publicationDate: Date?
    let type: SourceType

    // Explicitly omit:
    // - User notes
    // - Full text
    // - PDFs
    // - User ID
    // - Project name (unless generic)

    init(from source: Source) {
        self.title = source.title
        self.authors = source.authors
        self.abstract = source.abstract
        self.publicationDate = source.publicationDate
        self.type = source.type
    }
}
```

## Testing AI Features

### Mock LLM Provider

```swift
final class MockLLMProvider: LLMProvider {
    var mockResponses: [String: String] = [:]

    func generateCompletion(prompt: String, model: String) async throws -> String {
        if let mock = mockResponses[prompt] {
            return mock
        }
        return "{\"related\": false}"
    }

    func generateEmbedding(text: String) async throws -> [Float] {
        // Return deterministic embedding for testing
        return Array(repeating: 0.5, count: 1536)
    }
}

// Test
func testMissingLinkDetection() async throws {
    let mockProvider = MockLLMProvider()
    mockProvider.mockResponses["..."] = """
    {
      "related": true,
      "relationship": "supports",
      "confidence": 0.85,
      "reasoning": "Both papers study climate change impacts on agriculture"
    }
    """

    let engine = AISuggestionEngine(llmService: LLMService(primary: mockProvider))
    let suggestions = try await engine.detectMissingLinks(testGraphAnalysis)

    XCTAssertEqual(suggestions.count, 1)
    XCTAssertEqual(suggestions[0].type, .missingConnection)
}
```

## Performance Optimization

### Batching Requests

```swift
// Instead of: 100 sequential API calls
// Do: 10 batched calls with 10 items each

func batchProcess<T, R>(items: [T], batchSize: Int,
                        processor: @escaping ([T]) async throws -> [R]) async throws -> [R] {
    var results: [R] = []

    for batch in items.chunked(into: batchSize) {
        let batchResults = try await processor(Array(batch))
        results.append(contentsOf: batchResults)
    }

    return results
}
```

### Caching

```swift
final class AISuggestionCache {
    private var cache: [String: CachedSuggestion] = [:]
    private let ttl: TimeInterval = 24 * 3600 // 24 hours

    func get(projectId: UUID, type: SuggestionType) -> [AISuggestion]? {
        let key = "\(projectId)-\(type)"
        guard let cached = cache[key],
              Date().timeIntervalSince(cached.timestamp) < ttl else {
            return nil
        }
        return cached.suggestions
    }

    func set(projectId: UUID, type: SuggestionType, suggestions: [AISuggestion]) {
        let key = "\(projectId)-\(type)"
        cache[key] = CachedSuggestion(suggestions: suggestions, timestamp: Date())
    }
}
```

## Next Steps

1. Implement basic LLM client (OpenAI)
2. Build prompt templates
3. Implement missing link detection (simplest use case)
4. Add cost tracking and rate limiting
5. Test with real API on sample data
6. Implement consent UI
7. Add remaining suggestion types

## References

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Anthropic Claude API](https://docs.anthropic.com)
- [Embeddings for Semantic Search](https://openai.com/blog/introducing-text-and-code-embeddings)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)
