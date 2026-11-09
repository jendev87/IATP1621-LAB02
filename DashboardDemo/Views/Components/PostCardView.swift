//
//  PostCardView.swift
//  DashboardDemo
//
//  Frosted glassmorphic squircle card presenting PostItem details with vibrant micro-interactions.
//

import SwiftUI

/// Stateless component view rendering an individual PostItem card with frosted glass depth.
struct PostCardView: View {
    let post: PostItem
    let onBookmarkTapped: () -> Void
    let onCommentsTapped: () -> Void

    init(
        post: PostItem,
        onBookmarkTapped: @escaping () -> Void = {},
        onCommentsTapped: @escaping () -> Void = {}
    ) {
        self.post = post
        self.onBookmarkTapped = onBookmarkTapped
        self.onCommentsTapped = onCommentsTapped
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
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - Top Row: Vibrant Avatar, Name, Handle, Bookmark Button
            HStack(alignment: .center, spacing: 12) {
                // Gradient author avatar circle with rounded typography & soft glow shadow
                ZStack {
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 42, height: 42)
                        .shadow(color: Color.indigo.opacity(0.3), radius: 6, x: 0, y: 2)

                    Text(post.authorInitials)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.name ?? "Unknown Author")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("@\(post.author?.username.lowercased() ?? "user\(post.id)")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Interactive bookmark button with circular halo & spring animation
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        onBookmarkTapped()
                    }
                } label: {
                    ZStack {
                        if post.isBookmarked {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .transition(.scale.combined(with: .opacity))
                        }

                        Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.title3)
                            .foregroundStyle(post.isBookmarked ? Color.orange : Color.secondary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(post.isBookmarked ? "Remove bookmark" : "Bookmark post")
            }

            // MARK: - Middle: Title & Truncated Body Preview
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title.capitalized)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(post.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            // MARK: - Bottom Bar: Tinted Discussion Button & Post ID
            HStack(alignment: .center) {
                Button(action: onCommentsTapped) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .font(.caption)
                        Text("Discussion")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.indigo.opacity(0.1))
                    .foregroundStyle(Color.indigo)
                    .clipShape(Capsule())
                }
                .buttonStyle(.borderless)

                Spacer()

                Text(String(format: "#%03d", post.id))
                    .font(.caption.monospaced())
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
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
}

#Preview("PostCardView - Glassmorphism Default") {
    ZStack {
        Color.indigo.opacity(0.15).ignoresSafeArea()
        PostCardView(
            post: .mock,
            onBookmarkTapped: {},
            onCommentsTapped: {}
        )
        .padding()
    }
}

#Preview("PostCardView - Glassmorphism Bookmarked") {
    ZStack {
        Color.purple.opacity(0.15).ignoresSafeArea()
        PostCardView(
            post: .mockBookmarked,
            onBookmarkTapped: {},
            onCommentsTapped: {}
        )
        .padding()
    }
}
