//
//  Post.swift
//  DashboardDemo
//

import Foundation

/// Data model representing a post.
nonisolated struct Post: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String

    init(id: Int, userId: Int = 1, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

// MARK: - Mock / Preview Data
extension Post {
    static let mock = Post(
        id: 1,
        userId: 1,
        title: "Sample Post Title",
        body: "This is a sample post body used for SwiftUI previews and unit testing."
    )

    static let mockList: [Post] = [
        Post(id: 1, userId: 1, title: "SwiftUI Architecture", body: "Clean architecture using MVVM, Repositories, and Network services."),
        Post(id: 2, userId: 1, title: "Concurrency in Swift", body: "Using async/await and structured concurrency for robust networking."),
        Post(id: 3, userId: 2, title: "Protocol-Oriented Programming", body: "Decoupling services with protocols enables easy mocking and testing.")
    ]
}
