//
//  GraphTestData.swift
//  Research Web Crawler
//
//  Generates test data for graph visualization testing
//

import Foundation

struct GraphTestData {
    // MARK: - Sample Graph Generation

    /// Generate a sample graph with specified number of nodes
    static func generateSampleGraph(
        nodeCount: Int,
        connectionDensity: Float = 0.15,
        projectId: UUID = UUID()
    ) -> (Graph, [Source]) {
        var graph = Graph(projectId: projectId)
        var sources: [Source] = []

        // Generate nodes in a rough spherical distribution
        for i in 0..<nodeCount {
            let sourceId = UUID()

            // Distribute nodes in 3D space
            let theta = Float.random(in: 0...(2 * .pi))
            let phi = Float.random(in: 0...(2 * .pi))
            let radius = Float.random(in: 0.3...1.5)

            let x = radius * sin(theta) * cos(phi)
            let y = radius * sin(theta) * sin(phi)
            let z = radius * cos(theta)

            let position = SIMD3<Float>(x, y, z)

            // Random source type
            let sourceType = SourceType.allCases.randomElement() ?? .article

            // Create graph node
            let node = GraphNode(
                sourceId: sourceId,
                position: position,
                size: 0.05
            )
            graph.addNode(node)

            // Create source
            let source = Source(
                title: "Sample Source \(i + 1)",
                type: sourceType,
                projectId: projectId,
                addedBy: "test"
            )
            source.id = sourceId
            source.authors = ["Author \(i % 10 + 1)"]
            source.abstract = "This is a sample abstract for testing purposes."

            sources.append(source)
        }

        // Generate connections based on density
        let nodeIds = Array(graph.nodes.keys)
        let targetConnectionCount = Int(Float(nodeCount) * connectionDensity * Float(nodeCount))

        var connectionCount = 0
        while connectionCount < targetConnectionCount && connectionCount < nodeCount * (nodeCount - 1) / 2 {
            let fromId = nodeIds.randomElement()!
            let toId = nodeIds.randomElement()!

            guard fromId != toId else { continue }
            guard !graph.isConnected(from: fromId, to: toId) else { continue }

            let connectionType = ConnectionType.allCases.randomElement() ?? .related
            let connection = Connection(
                from: fromId,
                to: toId,
                type: connectionType,
                createdBy: "test"
            )

            graph.addEdge(connection)
            connectionCount += 1
        }

        return (graph, sources)
    }

    // MARK: - Predefined Test Cases

    /// Small graph for basic testing (10 nodes)
    static func smallGraph(projectId: UUID = UUID()) -> (Graph, [Source]) {
        return generateSampleGraph(nodeCount: 10, connectionDensity: 0.3, projectId: projectId)
    }

    /// Medium graph for interaction testing (50 nodes)
    static func mediumGraph(projectId: UUID = UUID()) -> (Graph, [Source]) {
        return generateSampleGraph(nodeCount: 50, connectionDensity: 0.15, projectId: projectId)
    }

    /// Large graph for performance testing (100 nodes)
    static func largeGraph(projectId: UUID = UUID()) -> (Graph, [Source]) {
        return generateSampleGraph(nodeCount: 100, connectionDensity: 0.1, projectId: projectId)
    }

    /// Star graph pattern (central hub with spokes)
    static func starGraph(projectId: UUID = UUID(), spokeCount: Int = 20) -> (Graph, [Source]) {
        var graph = Graph(projectId: projectId)
        var sources: [Source] = []

        // Create central node
        let centralId = UUID()
        let centralNode = GraphNode(
            sourceId: centralId,
            position: .zero,
            size: 0.08
        )
        graph.addNode(centralNode)

        let centralSource = Source(
            title: "Central Hub",
            type: .article,
            projectId: projectId,
            addedBy: "test"
        )
        centralSource.id = centralId
        sources.append(centralSource)

        // Create spoke nodes
        for i in 0..<spokeCount {
            let spokeId = UUID()
            let angle = Float(i) * (2 * .pi) / Float(spokeCount)
            let radius: Float = 1.0

            let position = SIMD3<Float>(
                radius * cos(angle),
                Float.random(in: -0.3...0.3),
                radius * sin(angle)
            )

            let spokeNode = GraphNode(
                sourceId: spokeId,
                position: position,
                size: 0.05
            )
            graph.addNode(spokeNode)

            let spokeSource = Source(
                title: "Spoke \(i + 1)",
                type: .article,
                projectId: projectId,
                addedBy: "test"
            )
            spokeSource.id = spokeId
            sources.append(spokeSource)

            // Connect to central hub
            let connection = Connection(
                from: centralId,
                to: spokeId,
                type: .related,
                createdBy: "test"
            )
            graph.addEdge(connection)
        }

        return (graph, sources)
    }

    /// Chain graph pattern (linear sequence)
    static func chainGraph(projectId: UUID = UUID(), length: Int = 10) -> (Graph, [Source]) {
        var graph = Graph(projectId: projectId)
        var sources: [Source] = []
        var previousId: UUID?

        for i in 0..<length {
            let nodeId = UUID()
            let position = SIMD3<Float>(
                Float(i) * 0.3 - Float(length) * 0.15,
                0,
                0
            )

            let node = GraphNode(
                sourceId: nodeId,
                position: position,
                size: 0.05
            )
            graph.addNode(node)

            let source = Source(
                title: "Node \(i + 1)",
                type: .article,
                projectId: projectId,
                addedBy: "test"
            )
            source.id = nodeId
            sources.append(source)

            // Connect to previous node
            if let prevId = previousId {
                let connection = Connection(
                    from: prevId,
                    to: nodeId,
                    type: .related,
                    createdBy: "test"
                )
                graph.addEdge(connection)
            }

            previousId = nodeId
        }

        return (graph, sources)
    }

    /// Clustered graph pattern (multiple small clusters)
    static func clusteredGraph(
        projectId: UUID = UUID(),
        clusterCount: Int = 5,
        nodesPerCluster: Int = 10
    ) -> (Graph, [Source]) {
        var graph = Graph(projectId: projectId)
        var sources: [Source] = []

        for clusterIdx in 0..<clusterCount {
            // Cluster center
            let clusterAngle = Float(clusterIdx) * (2 * .pi) / Float(clusterCount)
            let clusterRadius: Float = 2.0
            let clusterCenter = SIMD3<Float>(
                clusterRadius * cos(clusterAngle),
                0,
                clusterRadius * sin(clusterAngle)
            )

            var clusterNodeIds: [UUID] = []

            // Create nodes in cluster
            for i in 0..<nodesPerCluster {
                let nodeId = UUID()

                // Position relative to cluster center
                let offset = SIMD3<Float>(
                    Float.random(in: -0.3...0.3),
                    Float.random(in: -0.3...0.3),
                    Float.random(in: -0.3...0.3)
                )

                let node = GraphNode(
                    sourceId: nodeId,
                    position: clusterCenter + offset,
                    size: 0.05
                )
                graph.addNode(node)
                clusterNodeIds.append(nodeId)

                let source = Source(
                    title: "Cluster \(clusterIdx + 1) - Node \(i + 1)",
                    type: .article,
                    projectId: projectId,
                    addedBy: "test"
                )
                source.id = nodeId
                sources.append(source)
            }

            // Create connections within cluster
            for _ in 0..<(nodesPerCluster * 2) {
                let from = clusterNodeIds.randomElement()!
                let to = clusterNodeIds.randomElement()!

                if from != to && !graph.isConnected(from: from, to: to) {
                    let connection = Connection(
                        from: from,
                        to: to,
                        type: .related,
                        createdBy: "test"
                    )
                    graph.addEdge(connection)
                }
            }
        }

        return (graph, sources)
    }
}
