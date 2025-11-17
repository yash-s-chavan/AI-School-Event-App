import SwiftUI

struct AdminUnderReviewList: View {
    
    @ObservedObject var viewModel: FeedViewModel
    @Binding var postCount: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if viewModel.underReviewPosts.isEmpty {
                    Text("No posts under review.")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                    
                } else {
                    
                    ForEach(viewModel.underReviewPosts) { post in
                        VStack(spacing: 12) {
                            
                            FeedCardView(
                                viewModel: viewModel,
                                post: post,
                                onCommentTap: {},
                                showActions: false
                            )
                            
                            HStack(spacing: 16) {
                                
                                Button {
                                    Task {
                                        if let id = post.id {
                                            await viewModel.approvePost(postId: id)
                                            await refresh()
                                        }
                                    }
                                } label: {
                                    Text("Approve")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                                
                                Button {
                                    Task {
                                        if let id = post.id {
                                            await viewModel.rejectPost(postId: id)
                                            await refresh()
                                        }
                                    }
                                } label: {
                                    Text("Reject")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .task {
            await viewModel.fetchUnderReview()
        }
    }
    
    private func refresh() async {
        await viewModel.fetchUnderReview()
        
        if let newCount = await viewModel.fetchUnderReviewCount() {
            await MainActor.run {
                postCount = newCount
            }
        }
    }
}
