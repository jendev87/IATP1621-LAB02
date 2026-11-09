//
//  User.swift
//  DashboardDemo
//
//  Model representing an author / user.
//

import Foundation

/// Company details associated with a User.
nonisolated struct Company: Codable, Sendable, Equatable, Hashable {
    let name: String
    let catchPhrase: String?
    let bs: String?

    init(name: String, catchPhrase: String? = nil, bs: String? = nil) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bs = bs
    }
}

/// Domain model representing a user author in JSONPlaceholder.
nonisolated struct User: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let company: Company?

    init(
        id: Int,
        name: String,
        username: String,
        email: String,
        company: Company? = nil
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.company = company
    }
}

// MARK: - Mock Data
extension User {
    static let mock = User(
        id: 1,
        name: "Leanne Graham",
        username: "Bret",
        email: "Sincere@april.biz",
        company: Company(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net")
    )

    static let mockList: [User] = [
        User(id: 1, name: "Leanne Graham", username: "Bret", email: "Sincere@april.biz", company: Company(name: "Romaguera-Crona")),
        User(id: 2, name: "Ervin Howell", username: "Antonette", email: "Shanna@melissa.tv", company: Company(name: "Deckow-Crist")),
        User(id: 3, name: "Clementine Bauch", username: "Samantha", email: "Nathan@yesenia.net", company: Company(name: "Romaguera-Jacobson")),
        User(id: 4, name: "Patricia Lebsack", username: "Karianne", email: "Julianne.OConner@kory.org", company: Company(name: "Robel-Corkery")),
        User(id: 5, name: "Chelsey Dietrich", username: "Kamren", email: "Lucio_Hettinger@annie.ca", company: Company(name: "Keebler LLC"))
    ]
}
