//
//  PostDetailView.swift
//  DashboardDemo
//
//  Dedicated detail screen presenting full post content, author details, and inline discussion with glassmorphism.
//

import SwiftUI

/// Detail screen displaying full post content, author profile, and inline comments with frosted glass aesthetics.
struct PostDetailView: View {
    let post: PostItem
    private let repository: PostRepositoryProtocol

    @State private var comments: [Comment] = []
    @State private var isLoadingComments: Bool = true
    @State private var loadErrorMessage: String? = nil

    init(
        post: PostItem,
        repository: PostRepositoryProtocol = PostRepository()
    ) {
        self.post = post
        self.repository = repository
    }

    /// Vibrant multi-color diagonal gradient for author avatars
    private var avatarGradient: LinearGradient {
        LinearGradient(
            colors: [.indigo, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // MARK: - Ambient Background Layer with Blurred Color Orbs
            ambientBackgroundLayer

            // MARK: - Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Author Header Glass Card
                    authorHeaderCard

                    // Post Content Glass Card
                    postContentCard

                    // Discussion Section
                    discussionSection
                }
                .padding(16)
            }
        }
        .navigationTitle("Post #\(post.id)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadComments()
        }
    }

    // MARK: - Subviews

    /// Ambient decorative layer with system background and soft blurred color orbs
    private var ambientBackgroundLayer: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            GeometryReader { proxy in
                Circle()
                    .fill(Color.indigo.opacity(0.12))
                    .frame(width: proxy.size.width * 0.85, height: proxy.size.width * 0.85)
                    .blur(radius: 75)
                    .offset(x: -proxy.size.width * 0.25, y: -proxy.size.height * 0.08)

                Circle()
                    .fill(Color.purple.opacity(0.08))
                    .frame(width: proxy.size.width * 0.9, height: proxy.size.width * 0.9)
                    .blur(radius: 80)
                    .offset(x: proxy.size.width * 0.35, y: proxy.size.height * 0.3)
            }
            .ignoresSafeArea()
        }
    }

    /// Author profile container with frosted acrylic glass, gradient border, and elevated shadow
    private var authorHeaderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                // Vibrant gradient avatar circle with glowing shadow & rounded typography
                ZStack {
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.indigo.opacity(0.35), radius: 8, x: 0, y: 3)

                    Text(post.authorInitials)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(post.author?.name ?? "Unknown Author")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("@\(post.author?.username.lowercased() ?? "anonymous")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if post.isBookmarked {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 38, height: 38)

                        Image(systemName: "bookmark.fill")
                            .font(.headline)
                            .foregroundStyle(Color.orange)
                    }
                }
            }

            if post.author?.company != nil || post.author?.email != nil {
                Divider()
                    .opacity(0.6)

                VStack(alignment: .leading, spacing: 10) {
                    if let company = post.author?.company {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "building.2.fill")
                                .font(.caption)
                                .foregroundStyle(Color.indigo)
                                .frame(width: 16)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(company.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                if let phrase = company.catchPhrase, !phrase.isEmpty {
                                    Text(phrase)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    if let email = post.author?.email {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope.fill")
                                .font(.caption)
                                .foregroundStyle(Color.indigo)
                                .frame(width: 16)

                            Text(email.lowercased())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.primary.opacity(0.06),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    /// Full post content enclosed in a frosted glass card
    private var postContentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(post.title.capitalized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(post.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.primary.opacity(0.06),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    /// Inline discussion comments section with frosted acrylic comment cards
    private var discussionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Discussion", systemImage: "bubble.left.and.text.bubble.right.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if !comments.isEmpty {
                    Text("\(comments.count) comments")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.indigo.opacity(0.1))
                        .foregroundStyle(Color.indigo)
                        .clipShape(Capsule())
                }
            }

            if isLoadingComments {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.1)
                            .tint(.indigo)
                        Text("Loading discussion...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
            } else if comments.isEmpty {
                ContentUnavailableView(
                    "No Comments Yet",
                    systemImage: "bubble.left",
                    description: Text("Be the first to join the conversation on this post.")
                )
                .padding(.vertical, 16)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(comments) { comment in
                        commentCard(comment: comment)
                    }
                }
            }
        }
    }

    /// Frosted acrylic comment card
    private func commentCard(comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "envelope.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.indigo)

                Text(comment.email.lowercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.indigo)
                    .lineLimit(1)

                Spacer()
            }

            Text(comment.name.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(comment.body)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.primary.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Actions

    private func loadComments() async {
        isLoadingComments = true
        do {
            comments = try await repository.fetchComments(for: post.id)
            isLoadingComments = false
        } catch {
            comments = []
            loadErrorMessage = error.localizedDescription
            isLoadingComments = false
        }
    }
}

// MARK: - Previews
#Preview("PostDetailView - Glassmorphism Loaded") {
    NavigationStack {
        PostDetailView(
            post: .mock,
            repository: MockPostRepository(commentsToReturn: Comment.mockList)
        )
    }
}

#Preview("PostDetailView - Glassmorphism Empty Comments") {
    NavigationStack {
        PostDetailView(
            post: .mockBookmarked,
            repository: MockPostRepository(commentsToReturn: [])
        )
    }
}
