//
//  PostItem.swift
//  DashboardDemo
//
//  Presentation model combining post primitives, author details, and local state.
//

import Foundation

/// Combined presentation entity combining post content, author metadata, and local UI state.
nonisolated struct PostItem: Identifiable, Sendable, Equatable, Hashable {
    let id: Int
    let title: String
    let body: String
    var author: User?
    var isBookmarked: Bool

    init(
        id: Int,
        title: String,
        body: String,
        author: User? = nil,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.author = author
        self.isBookmarked = isBookmarked
    }

    /// Convenience initializer mapping from a raw Post DTO and optional User author.
    init(post: Post, author: User? = nil, isBookmarked: Bool = false) {
        self.init(
            id: post.id,
            title: post.title,
            body: post.body,
            author: author,
            isBookmarked: isBookmarked
        )
    }

    /// Computed initials helper for gradient avatar fallback rendering.
    var authorInitials: String {
        guard let name = author?.name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "U"
        }
        let parts = name.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if parts.count >= 2 {
            let first = parts[0].prefix(1).uppercased()
            let second = parts[1].prefix(1).uppercased()
            return "\(first)\(second)"
        } else if let single = parts.first, !single.isEmpty {
            return String(single.prefix(2)).uppercased()
        }
        return "U"
    }
}

// MARK: - Mock / Preview Data
extension PostItem {
    static let mock = PostItem(
        id: 1,
        title: "SwiftUI Architecture with Concurrency",
        body: "Clean architecture using MVVM, Repositories, and structured concurrency patterns for scalable iOS applications.",
        author: User.mock,
        isBookmarked: false
    )

    static let mockBookmarked = PostItem(
        id: 2,
        title: "Mastering Structured Concurrency in Swift 6",
        body: "Leverage async let, task groups, and actor isolation to write resilient, race-condition-free networking layers.",
        author: User.mockList[1],
        isBookmarked: true
    )

    static let mockList: [PostItem] = [
        PostItem(
            id: 1,
            title: "SwiftUI Architecture with Concurrency",
            body: "Clean architecture using MVVM, Repositories, and structured concurrency patterns for scalable iOS applications.",
            author: User.mockList[0],
            isBookmarked: false
        ),
        PostItem(
            id: 2,
            title: "Mastering Structured Concurrency in Swift 6",
            body: "Leverage async let, task groups, and actor isolation to write resilient, race-condition-free networking layers.",
            author: User.mockList[1],
            isBookmarked: true
        ),
        PostItem(
            id: 3,
            title: "Protocol-Oriented Programming in Practice",
            body: "Decoupling services with protocols enables modularity, testability, and seamless mock injection across SwiftUI previews.",
            author: User.mockList[2],
            isBookmarked: false
        ),
        PostItem(
            id: 4,
            title: "Designing Fluid Modern Micro-Interactions",
            body: "Elevate your native iOS interface using spring animations, symbol effects, and subtle tactile responses.",
            author: User.mockList[3],
            isBookmarked: false
        ),
        PostItem(
            id: 5,
            title: "State Management with the Observation Framework",
            body: "Explore @Observable macro improvements over ObservableObject, minimizing unnecessary view re-evaluations.",
            author: User.mockList[4],
            isBookmarked: true
        )
    ]
}
