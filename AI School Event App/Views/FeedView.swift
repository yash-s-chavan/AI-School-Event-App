import SwiftUI

struct FeedView: View {
    let sorts = ["Relevant", "Recent", "Top"]
    let filters = ["All Categories", "Events", "Sports", "Arts", "Technology", "Music"]

    @State private var selectedSort = "Relevant"
    @State private var selectedFilter = "All Categories"

    @StateObject private var viewModel = FeedViewModel()

    @State private var showComments = false
    @State private var selectedPost: PostModel? = nil
    @State private var newComment = ""

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("Campus Q&A Feed")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("View recent questions and AI responses")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)

                Divider().padding(.vertical, 10)

                HStack(spacing: 16) {
                    ForEach(sorts, id: \.self) { sort in
                        Button {
                            selectedSort = sort
                            Task { await viewModel.fetchPosts(sortedBy: sort) }
                        } label: {
                            Text(sort)
                                .tint(.black)
                                .frame(maxWidth: .infinity)
                                .fontWeight(selectedSort == sort ? .bold : .regular)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .background(selectedSort == sort ? .white : .clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal)

                Divider().padding(.vertical, 10)

                HStack {
                    Image(systemName: "line.3.horizontal.decrease")

                    Picker("All Categories", selection: $selectedFilter) {
                        ForEach(filters, id: \.self) { filter in
                            Text(filter)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .frame(maxHeight: 30)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)

                    Spacer()
                }

                Divider().padding(.vertical, 10)

                ScrollView {
                    VStack(spacing: 20) {
                        let filteredPosts = viewModel.posts.filter { post in
                            selectedFilter == "All Categories" || post.category == selectedFilter
                        }

                        if filteredPosts.isEmpty {
                            Text("No posts found for \(selectedFilter)")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        } else {
                            ForEach(filteredPosts) { post in
                                FeedCardView(
                                    viewModel: viewModel,
                                    post: post,
                                    onCommentTap: {
                                        selectedPost = post
                                        withAnimation(.spring()) {
                                            showComments = true
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .task { await viewModel.fetchPosts(sortedBy: selectedSort) }
            }

            if showComments,
               let original = selectedPost,
               let refreshed = viewModel.posts.first(where: { $0.id == original.id }) {

                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { showComments = false }
                    }

                CommentPopupView(
                    comments: refreshed.comments,
                    newComment: $newComment,
                    onClose: { withAnimation(.spring()) { showComments = false } },
                    onPost: {
                        Task {
                            if let id = refreshed.id {
                                await viewModel.postComment(postId: id, content: newComment)
                                newComment = ""
                            }
                        }
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    FeedView()
}
