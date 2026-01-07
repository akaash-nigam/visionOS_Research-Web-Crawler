//
//  SampleDataGenerator.swift
//  Research Web Crawler
//
//  Generates sample project and data for tutorials and demonstrations
//

import Foundation

@MainActor
struct SampleDataGenerator {

    static func generateSampleProject(persistenceManager: PersistenceManager) -> Project {
        let project = Project(
            name: "Sample Research Project",
            description: "An example project demonstrating the Research Web Crawler's capabilities. Explore AI and machine learning research.",
            ownerId: "demo_user"
        )

        persistenceManager.saveProject(project)

        // Generate sample sources
        let sources = generateSampleSources(for: project.id)

        for source in sources {
            persistenceManager.saveSource(source)
        }

        // Add references between sources
        addSampleReferences(to: sources, persistenceManager: persistenceManager)

        return project
    }

    private static func generateSampleSources(for projectId: UUID) -> [Source] {
        var sources: [Source] = []

        // Source 1: Foundational paper
        let source1 = Source(
            title: "Attention Is All You Need",
            type: .academicPaper,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source1.authors = ["Ashish Vaswani", "Noam Shazeer", "Niki Parmar", "Jakob Uszkoreit"]
        source1.abstract = "The dominant sequence transduction models are based on complex recurrent or convolutional neural networks. We propose a new simple network architecture, the Transformer, based solely on attention mechanisms."
        source1.publicationDate = createDate(year: 2017, month: 6, day: 12)
        source1.journal = "Advances in Neural Information Processing Systems"
        source1.doi = "10.48550/arXiv.1706.03762"
        source1.url = "https://arxiv.org/abs/1706.03762"
        source1.tags = ["transformers", "attention", "NLP", "deep learning"]
        source1.isFavorite = true
        sources.append(source1)

        // Source 2: GPT paper
        let source2 = Source(
            title: "Language Models are Few-Shot Learners",
            type: .academicPaper,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source2.authors = ["Tom B. Brown", "Benjamin Mann", "Nick Ryder", "Melanie Subbiah"]
        source2.abstract = "We demonstrate that scaling up language models greatly improves task-agnostic, few-shot performance, reaching competitive or state-of-the-art results on many NLP tasks."
        source2.publicationDate = createDate(year: 2020, month: 5, day: 28)
        source2.journal = "Advances in Neural Information Processing Systems"
        source2.doi = "10.48550/arXiv.2005.14165"
        source2.url = "https://arxiv.org/abs/2005.14165"
        source2.tags = ["GPT-3", "language models", "few-shot learning", "NLP"]
        sources.append(source2)

        // Source 3: Vision transformers
        let source3 = Source(
            title: "An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale",
            type: .academicPaper,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source3.authors = ["Alexey Dosovitskiy", "Lucas Beyer", "Alexander Kolesnikov"]
        source3.abstract = "While the Transformer architecture has become the de-facto standard for natural language processing tasks, its applications to computer vision remain limited."
        source3.publicationDate = createDate(year: 2020, month: 10, day: 22)
        source3.journal = "International Conference on Learning Representations"
        source3.doi = "10.48550/arXiv.2010.11929"
        source3.url = "https://arxiv.org/abs/2010.11929"
        source3.tags = ["vision", "transformers", "computer vision", "ViT"]
        sources.append(source3)

        // Source 4: Book on deep learning
        let source4 = Source(
            title: "Deep Learning",
            type: .book,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source4.authors = ["Ian Goodfellow", "Yoshua Bengio", "Aaron Courville"]
        source4.abstract = "An introduction to a broad range of topics in deep learning, covering mathematical and conceptual background, deep learning techniques used in industry, and research perspectives."
        source4.publicationDate = createDate(year: 2016, month: 11, day: 18)
        source4.publisher = "MIT Press"
        source4.isbn = "978-0262035613"
        source4.url = "https://www.deeplearningbook.org/"
        source4.tags = ["deep learning", "textbook", "neural networks", "foundations"]
        source4.isFavorite = true
        sources.append(source4)

        // Source 5: Recent article
        let source5 = Source(
            title: "The State of AI in 2023",
            type: .article,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source5.authors = ["Various Authors"]
        source5.abstract = "A comprehensive review of artificial intelligence developments in 2023, including large language models, multimodal AI, and emerging applications."
        source5.publicationDate = createDate(year: 2023, month: 12, day: 1)
        source5.url = "https://example.com/ai-2023"
        source5.tags = ["AI", "survey", "2023", "trends"]
        sources.append(source5)

        // Source 6: BERT paper
        let source6 = Source(
            title: "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding",
            type: .academicPaper,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source6.authors = ["Jacob Devlin", "Ming-Wei Chang", "Kenton Lee", "Kristina Toutanova"]
        source6.abstract = "We introduce a new language representation model called BERT, which stands for Bidirectional Encoder Representations from Transformers."
        source6.publicationDate = createDate(year: 2018, month: 10, day: 11)
        source6.journal = "NAACL-HLT"
        source6.doi = "10.48550/arXiv.1810.04805"
        source6.url = "https://arxiv.org/abs/1810.04805"
        source6.tags = ["BERT", "transformers", "NLP", "pre-training"]
        sources.append(source6)

        // Source 7: Reinforcement learning
        let source7 = Source(
            title: "Mastering the Game of Go with Deep Neural Networks and Tree Search",
            type: .academicPaper,
            projectId: projectId,
            addedBy: "demo_user"
        )
        source7.authors = ["David Silver", "Aja Huang", "Chris J. Maddison"]
        source7.abstract = "The game of Go has long been viewed as the most challenging of classic games for artificial intelligence. Here we introduce a new approach to computer Go that uses value networks to evaluate board positions and policy networks to select moves."
        source7.publicationDate = createDate(year: 2016, month: 1, day: 27)
        source7.journal = "Nature"
        source7.doi = "10.1038/nature16961"
        source7.url = "https://www.nature.com/articles/nature16961"
        source7.tags = ["reinforcement learning", "AlphaGo", "games", "deep learning"]
        source7.isFavorite = true
        sources.append(source7)

        return sources
    }

    private static func addSampleReferences(to sources: [Source], persistenceManager: PersistenceManager) {
        guard sources.count >= 7 else { return }

        // Source 2 (GPT-3) references Source 1 (Transformers)
        sources[1].addReference(to: sources[0].id, type: "references")

        // Source 3 (ViT) references Source 1 (Transformers)
        sources[2].addReference(to: sources[0].id, type: "references")

        // Source 6 (BERT) references Source 1 (Transformers)
        sources[5].addReference(to: sources[0].id, type: "references")

        // Source 5 (State of AI) references multiple sources
        sources[4].addReference(to: sources[1].id, type: "references")
        sources[4].addReference(to: sources[2].id, type: "references")

        // Source 2 references the textbook
        sources[1].addReference(to: sources[3].id, type: "related")

        // Source 7 (AlphaGo) references textbook
        sources[6].addReference(to: sources[3].id, type: "related")

        // Save all updated sources
        for source in sources {
            persistenceManager.saveSource(source)
        }
    }

    private static func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Sample Collection

    static func generateSampleCollection(for project: Project, sources: [Source], persistenceManager: PersistenceManager) -> Collection {
        let collection = Collection(
            name: "Transformer Papers",
            description: "Key papers on transformer architecture and its applications",
            projectId: project.id,
            createdBy: "demo_user"
        )

        // Add transformer-related sources
        let transformerSources = sources.filter { source in
            source.tags.contains { tag in
                tag.lowercased().contains("transformer")
            }
        }

        for source in transformerSources {
            collection.addSource(source.id)
        }

        persistenceManager.saveCollection(collection)
        return collection
    }

    // MARK: - Demo Notes

    static func addSampleNotes(to source: Source) {
        switch source.title {
        case "Attention Is All You Need":
            source.notes = """
            Groundbreaking paper that introduced the Transformer architecture.
            Key innovations:
            - Self-attention mechanism
            - Positional encoding
            - Multi-head attention
            - No recurrence required

            Impact: Foundation for modern NLP models (BERT, GPT, etc.)
            """

        case "Deep Learning":
            source.notes = """
            Comprehensive textbook covering:
            - Chapters 6-12: Deep feedforward networks, regularization, optimization
            - Chapters 13-20: CNNs, RNNs, applications

            Excellent resource for understanding fundamentals.
            """

        default:
            source.notes = "Sample notes for demonstration purposes."
        }
    }

    // MARK: - Generate Quick Start Project

    static func generateQuickStartProject(persistenceManager: PersistenceManager) -> Project {
        let project = Project(
            name: "Quick Start Tutorial",
            description: "Follow along with this project to learn the basics",
            ownerId: "tutorial_user"
        )

        persistenceManager.saveProject(project)

        // Add just 3 sources for simplicity
        let sources = generateQuickStartSources(for: project.id)

        for source in sources {
            persistenceManager.saveSource(source)
        }

        return project
    }

    private static func generateQuickStartSources(for projectId: UUID) -> [Source] {
        let source1 = Source(
            title: "Introduction to Research Management",
            type: .article,
            projectId: projectId,
            addedBy: "tutorial_user"
        )
        source1.authors = ["Tutorial Author"]
        source1.abstract = "Learn the basics of organizing research with digital tools."
        source1.tags = ["tutorial", "basics"]

        let source2 = Source(
            title: "Advanced Research Techniques",
            type: .article,
            projectId: projectId,
            addedBy: "tutorial_user"
        )
        source2.authors = ["Tutorial Author"]
        source2.abstract = "Build on the basics with advanced organizational strategies."
        source2.tags = ["tutorial", "advanced"]
        source2.addReference(to: source1.id)

        let source3 = Source(
            title: "Research Best Practices",
            type: .book,
            projectId: projectId,
            addedBy: "tutorial_user"
        )
        source3.authors = ["Expert Researcher"]
        source3.abstract = "A comprehensive guide to research methodology."
        source3.tags = ["tutorial", "reference"]

        return [source1, source2, source3]
    }
}
