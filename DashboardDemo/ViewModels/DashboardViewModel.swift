//
//  DashboardViewModel.swift
//  DashboardDemo
//
//  Coordinates between PostRepository and UI with modern Swift Concurrency.
//

import Foundation
import Observation

/// View state representing the lifecycle of feed data fetching.
enum DashboardViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

/// MainActor isolated ViewModel managing feed state, filters, and comment discussions.
@Observable
@MainActor
final class DashboardViewModel {
    // MARK: - Feed & Filter State Properties
    var viewState: DashboardViewState = .idle
    var searchText: String = ""
    var selectedAuthorId: Int? = nil
    var bookmarkedOnly: Bool = false

    // MARK: - Comments Sheet State
    var activePostForComments: PostItem? = nil
    var comments: [Comment] = []
    var isCommentsLoading: Bool = false

    // MARK: - Feed Storage
    private(set) var posts: [PostItem] = []

    // MARK: - Dependencies
    private let repository: PostRepositoryProtocol

    // MARK: - Initialization
    init(
        repository: PostRepositoryProtocol = PostRepository(),
        initialPosts: [PostItem] = [],
        initialViewState: DashboardViewState = .idle
    ) {
        self.repository = repository
        self.posts = initialPosts
        if !initialPosts.isEmpty {
            self.viewState = .loaded
        } else {
            self.viewState = initialViewState
        }
    }

    // MARK: - Computed Properties

    /// Deduplicated list of authors from loaded posts, sorted alphabetically.
    var availableAuthors: [User] {
        let allAuthors = posts.compactMap(\.author)
        var seenIds = Set<Int>()
        var uniqueAuthors: [User] = []

        for author in allAuthors {
            if seenIds.insert(author.id).inserted {
                uniqueAuthors.append(author)
            }
        }

        return uniqueAuthors.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    /// Posts filtered concurrently by search query, selected author, and bookmark status.
    var filteredPosts: [PostItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return posts.filter { item in
            // 1. Author Filter
            if let selectedAuthorId {
                guard item.author?.id == selectedAuthorId else { return false }
            }

            // 2. Bookmark Only Filter
            if bookmarkedOnly {
                guard item.isBookmarked else { return false }
            }

            // 3. Search Query Filter (title, body, author name, author username)
            if !query.isEmpty {
                let matchesTitle = item.title.localizedCaseInsensitiveContains(query)
                let matchesBody = item.body.localizedCaseInsensitiveContains(query)
                let matchesAuthorName = item.author?.name.localizedCaseInsensitiveContains(query) ?? false
                let matchesUsername = item.author?.username.localizedCaseInsensitiveContains(query) ?? false

                guard matchesTitle || matchesBody || matchesAuthorName || matchesUsername else {
                    return false
                }
            }

            return true
        }
    }

    /// Helper flag to indicate whether data is loading.
    var isLoading: Bool {
        viewState == .loading
    }

    /// Flag indicating whether any filter (search, author, or bookmark) is currently active.
    var isFilteringActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        selectedAuthorId != nil ||
        bookmarkedOnly
    }

    // MARK: - Action Methods

    /// Fetches the feed from the repository using structured concurrency.
    func loadFeed() async {
        viewState = .loading
        do {
            let fetchedFeed = try await repository.fetchFeed()
            // Preserve local bookmark states across feed refreshes
            let currentBookmarkedIds = Set(posts.filter(\.isBookmarked).map(\.id))
            self.posts = fetchedFeed.map { item in
                var updated = item
                if currentBookmarkedIds.contains(item.id) {
                    updated.isBookmarked = true
                }
                return updated
            }
            self.viewState = .loaded
        } catch {
            self.viewState = .error(error.localizedDescription)
        }
    }

    /// Toggles the bookmark status for a specific post.
    func toggleBookmark(for postId: Int) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isBookmarked.toggle()
            if activePostForComments?.id == postId {
                activePostForComments?.isBookmarked = posts[index].isBookmarked
            }
        }
    }

    /// Sets up the active post for comments and initiates fetching discussion comments.
    func showComments(for post: PostItem) {
        activePostForComments = post
        comments = []
        isCommentsLoading = true

        Task {
            await fetchComments(for: post.id)
        }
    }

    /// Fetches discussion comments asynchronously for the given post.
    func fetchComments(for postId: Int) async {
        isCommentsLoading = true
        do {
            let fetchedComments = try await repository.fetchComments(for: postId)
            guard activePostForComments?.id == postId else { return }
            self.comments = fetchedComments
            self.isCommentsLoading = false
        } catch {
            guard activePostForComments?.id == postId else { return }
            self.comments = []
            self.isCommentsLoading = false
        }
    }

    /// Selects or deselects an author filter pill.
    func selectAuthor(_ authorId: Int?) {
        if selectedAuthorId == authorId {
            selectedAuthorId = nil
        } else {
            selectedAuthorId = authorId
        }
    }

    /// Clears all active filters.
    func resetFilters() {
        searchText = ""
        selectedAuthorId = nil
        bookmarkedOnly = false
    }
}
