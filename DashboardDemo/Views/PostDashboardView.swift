//
//  PostDashboardView.swift
//  DashboardDemo
//
//  Main dashboard feed view with ambient glassmorphism, author filtering, bookmarks, and tactile navigation.
//

import SwiftUI

/// Main dashboard view displaying a native feature feed with ambient glass depth and spring interactions.
struct PostDashboardView: View {
    @State private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? DashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Author Filter Carousel (Top of Feed)
                    if !viewModel.availableAuthors.isEmpty {
                        authorFilterCarousel
                            .padding(.top, 4)
                    }

                    // MARK: - Feed Content State Handling
                    Group {
                        switch viewModel.viewState {
                        case .idle, .loading:
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.indigo)
                                Text("Loading feed...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)

                        case .loaded:
                            if viewModel.filteredPosts.isEmpty {
                                searchMissView
                                    .padding(.top, 32)
                            } else {
                                feedCardsList
                            }

                        case .error(let message):
                            errorStateView(message: message)
                                .padding(.top, 40)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(ambientBackgroundLayer)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search posts, authors, or handles"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.bookmarkedOnly.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.bookmarkedOnly ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(viewModel.bookmarkedOnly ? Color.orange : Color.primary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .accessibilityLabel(viewModel.bookmarkedOnly ? "Show all posts" : "Show bookmarked posts only")
                }
            }
            .refreshable {
                await viewModel.loadFeed()
            }
            .task {
                if viewModel.viewState == .idle {
                    await viewModel.loadFeed()
                }
            }
            .sheet(item: $viewModel.activePostForComments) { post in
                CommentsSheetView(
                    post: post,
                    comments: viewModel.comments,
                    isLoading: viewModel.isCommentsLoading
                )
            }
            .navigationDestination(for: PostItem.self) { post in
                PostDetailView(post: post)
            }
        }
    }

    // MARK: - Subviews

    /// Ambient decorative layer with system grouped background and soft blurred color orbs
    private var ambientBackgroundLayer: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            Circle()
                .fill(Color.indigo.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 75)
                .offset(x: -100, y: -160)

            Circle()
                .fill(Color.purple.opacity(0.08))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: 120, y: 140)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// Horizontal author filter carousel pills right above the feed
    private var authorFilterCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Authors",
                    isSelected: viewModel.selectedAuthorId == nil
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectAuthor(nil)
                    }
                }

                ForEach(viewModel.availableAuthors) { author in
                    FilterChip(
                        title: author.name,
                        subtitle: "@\(author.username.lowercased())",
                        isSelected: viewModel.selectedAuthorId == author.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectAuthor(author.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    /// Feed list rendering individual PostCardView components with tactile spring feedback
    private var feedCardsList: some View {
        LazyVStack(spacing: 14) {
            ForEach(viewModel.filteredPosts) { post in
                NavigationLink(value: post) {
                    PostCardView(
                        post: post,
                        onBookmarkTapped: {
                            viewModel.toggleBookmark(for: post.id)
                        },
                        onCommentsTapped: {
                            viewModel.showComments(for: post)
                        }
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }

    /// Search miss or active filter empty state
    private var searchMissView: some View {
        ContentUnavailableView {
            Label(
                viewModel.bookmarkedOnly ? "No Bookmarked Posts" : "No Matching Posts",
                systemImage: viewModel.bookmarkedOnly ? "bookmark.slash" : "doc.text.magnifyingglass"
            )
        } description: {
            Text(
                viewModel.bookmarkedOnly
                    ? "You haven't bookmarked any posts yet. Tap the bookmark icon on any card to save it."
                    : "No posts match your search query or author filter."
            )
        } actions: {
            if viewModel.isFilteringActive {
                Button("Reset Filters") {
                    withAnimation {
                        viewModel.resetFilters()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    /// Network error unavailable view with retry action
    private func errorStateView(message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Feed", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadFeed()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

// MARK: - Previews
#Preview("PostDashboardView - Loaded Glassmorphic") {
    PostDashboardView(
        viewModel: DashboardViewModel(
            repository: MockPostRepository(feedToReturn: PostItem.mockList),
            initialPosts: PostItem.mockList
        )
    )
}

#Preview("PostDashboardView - Error") {
    PostDashboardView(
        viewModel: DashboardViewModel(
            repository: MockPostRepository(shouldFail: true),
            initialViewState: .error("The network connection was lost.")
        )
    )
}

#Preview("PostDashboardView - Empty Search Miss") {
    let vm = DashboardViewModel(
        repository: MockPostRepository(feedToReturn: PostItem.mockList),
        initialPosts: PostItem.mockList
    )
    vm.searchText = "NonExistentQuery"
    return PostDashboardView(viewModel: vm)
}
