//
//  Comment.swift
//  DashboardDemo
//
//  Model representing a post discussion comment.
//

import Foundation

/// Domain model representing a comment on a post.
nonisolated struct Comment: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String

    init(
        id: Int,
        postId: Int,
        name: String,
        email: String,
        body: String
    ) {
        self.id = id
        self.postId = postId
        self.name = name
        self.email = email
        self.body = body
    }
}

// MARK: - Mock Data
extension Comment {
    static let mock = Comment(
        id: 1,
        postId: 1,
        name: "id labore ex et quam laborum",
        email: "Eliseo@gardner.biz",
        body: "Laudantium enim quasi est quidem magnam voluptate ipsam eos tempora quo necessitatibus dolor quam autem quasi."
    )

    static let mockList: [Comment] = [
        Comment(
            id: 1,
            postId: 1,
            name: "id labore ex et quam laborum",
            email: "Eliseo@gardner.biz",
            body: "Laudantium enim quasi est quidem magnam voluptate ipsam eos tempora quo necessitatibus dolor quam autem quasi reiciendis et nam sapiente accusantium."
        ),
        Comment(
            id: 2,
            postId: 1,
            name: "quo vero reiciendis velit similique earum",
            email: "Jayne_Kuhic@sydney.com",
            body: "Est natus enim nihil est dolore omnis voluptatem numquam et omnis occaecati quod ullam at voluptatem error."
        ),
        Comment(
            id: 3,
            postId: 1,
            name: "odio adipisci rerum aut animi",
            email: "Nikita@garfield.biz",
            body: "Quia molestiae reprehenderit quasi aspernatur aut expedita occaecati aliquam eveniet laudantium voluptatem eos alias."
        )
    ]
}
