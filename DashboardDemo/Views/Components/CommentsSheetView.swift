//
//  CommentsSheetView.swift
//  DashboardDemo
//
//  Stateless bottom sheet view displaying discussion comments with frosted glassmorphism.
//

import SwiftUI

/// Bottom sheet displaying discussions and comments for a given post with glassmorphic aesthetics.
struct CommentsSheetView: View {
    let post: PostItem
    let comments: [Comment]
    let isLoading: Bool

    @Environment(\.dismiss) private var dismiss

    init(
        post: PostItem,
        comments: [Comment],
        isLoading: Bool
    ) {
        self.post = post
        self.comments = comments
        self.isLoading = isLoading
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
        NavigationStack {
            ZStack {
                // MARK: - Ambient Background Layer
                ambientBackgroundLayer

                // MARK: - Content
                Group {
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.indigo)
                            Text("Loading discussion...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if comments.isEmpty {
                        ContentUnavailableView(
                            "No Comments Yet",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Be the first to join the conversation on this post.")
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Context Header Glass Card
                                contextHeaderCard

                                // Comments Count Pill
                                HStack {
                                    Label("Discussion", systemImage: "bubble.left.and.text.bubble.right.fill")
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Text("\(comments.count) comments")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.indigo.opacity(0.1))
                                        .foregroundStyle(Color.indigo)
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 4)
                                .padding(.top, 4)

                                // Discussion Comments List
                                LazyVStack(spacing: 12) {
                                    ForEach(comments) { comment in
                                        commentCard(comment: comment)
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Discussion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .tint(.indigo)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    /// Ambient decorative layer with system background and soft blurred color orbs
    private var ambientBackgroundLayer: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            GeometryReader { proxy in
                Circle()
                    .fill(Color.indigo.opacity(0.14))
                    .frame(width: proxy.size.width * 0.75, height: proxy.size.width * 0.75)
                    .blur(radius: 65)
                    .offset(x: -proxy.size.width * 0.2, y: -proxy.size.height * 0.05)

                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: proxy.size.width * 0.8, height: proxy.size.width * 0.8)
                    .blur(radius: 70)
                    .offset(x: proxy.size.width * 0.3, y: proxy.size.height * 0.25)
            }
            .ignoresSafeArea()
        }
    }

    /// Post context header card with frosted glass depth
    private var contextHeaderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title.capitalized)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(2)

            if let author = post.author {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(avatarGradient)
                            .frame(width: 26, height: 26)
                            .shadow(color: Color.indigo.opacity(0.3), radius: 3, x: 0, y: 1)

                        Text(post.authorInitials)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Text(author.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("@\(author.username.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    /// Frosted acrylic comment card
    private func commentCard(comment: Comment) -> some View {
        let initials = emailInitials(for: comment.email)

        return VStack(alignment: .leading, spacing: 8) {
            // Header with avatar & sender email
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.12))
                        .frame(width: 28, height: 28)

                    Text(initials)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.indigo)
                }

                Text(comment.email.lowercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.indigo)
                    .lineLimit(1)

                Spacer()
            }

            // Subject / Title
            Text(comment.name.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            // Body
            Text(comment.body)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
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

    private func emailInitials(for email: String) -> String {
        let namePart = email.components(separatedBy: "@").first ?? ""
        let cleaned = namePart.replacingOccurrences(of: ".", with: " ").replacingOccurrences(of: "_", with: " ")
        let words = cleaned.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if words.count >= 2 {
            let f = words[0].prefix(1).uppercased()
            let s = words[1].prefix(1).uppercased()
            return "\(f)\(s)"
        } else if let single = words.first, !single.isEmpty {
            return String(single.prefix(2)).uppercased()
        }
        return "C"
    }
}

// MARK: - Previews
#Preview("CommentsSheetView - Glassmorphism Loaded") {
    CommentsSheetView(
        post: .mock,
        comments: Comment.mockList,
        isLoading: false
    )
}

#Preview("CommentsSheetView - Glassmorphism Loading") {
    CommentsSheetView(
        post: .mock,
        comments: [],
        isLoading: true
    )
}

#Preview("CommentsSheetView - Glassmorphism Empty") {
    CommentsSheetView(
        post: .mock,
        comments: [],
        isLoading: false
    )
}
