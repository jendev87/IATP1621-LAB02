//
//  PostRepository.swift
//  DashboardDemo
//
//  Protocol + Concrete implementation coordinating NetworkService
//

import Foundation

/// Protocol defining the interface for fetching post feed, users, and comments.
protocol PostRepositoryProtocol: Sendable {
    func fetchFeed() async throws -> [PostItem]
    func fetchPosts() async throws -> [Post]
    func fetchUsers() async throws -> [User]
    func fetchComments(for postId: Int) async throws -> [Comment]
    func fetchPost(id: Int) async throws -> Post
}

/// Concrete repository implementation that coordinates with NetworkService.
final class PostRepository: PostRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
    ) {
        self.networkService = networkService
        self.baseURL = baseURL
    }

    /// Fetches posts and users in parallel using structured concurrency (async let),
    /// combining them into domain PostItem entities using an O(1) hash map dictionary.
    func fetchFeed() async throws -> [PostItem] {
        guard let postsURL = URL(string: "\(baseURL.absoluteString)/posts"),
              let usersURL = URL(string: "\(baseURL.absoluteString)/users") else {
            throw NetworkError.invalidURL
        }

        // Parallel fetch using structured concurrency
        async let postsTask: [Post] = networkService.fetchData(from: postsURL)
        async let usersTask: [User] = networkService.fetchData(from: usersURL)

        let (posts, users) = try await (postsTask, usersTask)

        // O(1) hash map dictionary mapping author id to User entity
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

        return posts.map { post in
            PostItem(
                id: post.id,
                title: post.title,
                body: post.body,
                author: userMap[post.userId],
                isBookmarked: false
            )
        }
    }

    /// Fetches all comments for a specific post hitting /posts/{id}/comments
    func fetchComments(for postId: Int) async throws -> [Comment] {
        guard let url = URL(string: "\(baseURL.absoluteString)/posts/\(postId)/comments") else {
            throw NetworkError.invalidURL
        }
        return try await networkService.fetchData(from: url)
    }

    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL.absoluteString)/posts") else {
            throw NetworkError.invalidURL
        }
        return try await networkService.fetchData(from: url)
    }

    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL.absoluteString)/users") else {
            throw NetworkError.invalidURL
        }
        return try await networkService.fetchData(from: url)
    }

    func fetchPost(id: Int) async throws -> Post {
        guard let url = URL(string: "\(baseURL.absoluteString)/posts/\(id)") else {
            throw NetworkError.invalidURL
        }
        return try await networkService.fetchData(from: url)
    }
}

// MARK: - Mock Repository for Testing / Previews
final class MockPostRepository: PostRepositoryProtocol, @unchecked Sendable {
    var feedToReturn: [PostItem]
    var postsToReturn: [Post]
    var usersToReturn: [User]
    var commentsToReturn: [Comment]
    var shouldFail: Bool

    init(
        feedToReturn: [PostItem] = PostItem.mockList,
        postsToReturn: [Post] = Post.mockList,
        usersToReturn: [User] = User.mockList,
        commentsToReturn: [Comment] = Comment.mockList,
        shouldFail: Bool = false
    ) {
        self.feedToReturn = feedToReturn
        self.postsToReturn = postsToReturn
        self.usersToReturn = usersToReturn
        self.commentsToReturn = commentsToReturn
        self.shouldFail = shouldFail
    }

    func fetchFeed() async throws -> [PostItem] {
        if shouldFail {
            throw NetworkError.underlying("Simulated repository failure.")
        }
        return feedToReturn
    }

    func fetchComments(for postId: Int) async throws -> [Comment] {
        if shouldFail {
            throw NetworkError.underlying("Simulated repository failure.")
        }
        let filtered = commentsToReturn.filter { $0.postId == postId }
        return filtered.isEmpty ? commentsToReturn : filtered
    }

    func fetchPosts() async throws -> [Post] {
        if shouldFail {
            throw NetworkError.underlying("Simulated repository failure.")
        }
        return postsToReturn
    }

    func fetchUsers() async throws -> [User] {
        if shouldFail {
            throw NetworkError.underlying("Simulated repository failure.")
        }
        return usersToReturn
    }

    func fetchPost(id: Int) async throws -> Post {
        if shouldFail {
            throw NetworkError.underlying("Simulated repository failure.")
        }
        guard let post = postsToReturn.first(where: { $0.id == id }) else {
            throw NetworkError.underlying("Post not found.")
        }
        return post
    }
}
