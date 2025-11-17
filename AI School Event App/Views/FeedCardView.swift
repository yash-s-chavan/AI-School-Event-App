import SwiftUI

struct FeedCardView: View {
    @ObservedObject var viewModel: FeedViewModel
    var post: PostModel
    var onCommentTap: () -> Void = {}
    var showActions: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(post.username.prefix(1)))
                            .font(.headline)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .fontWeight(.semibold)

                    Text((post.timestamp ?? "").timeAgo())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(post.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            Text(post.question)
                .font(.body)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 6) {
                Text("AI Response")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)

                Text(post.aiResponse)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            if showActions {
                HStack(spacing: 20) {
                    Button {
                        Task {
                            if let id = post.id {
                                await viewModel.updateReaction(postId: id, type: "like")
                            }
                        }
                    } label: {
                        Label("\(post.likes)", systemImage: "hand.thumbsup")
                            .foregroundColor(.black)
                    }

                    Button {
                        Task {
                            if let id = post.id {
                                await viewModel.updateReaction(postId: id, type: "dislike")
                            }
                        }
                    } label: {
                        Label("\(post.dislikes)", systemImage: "hand.thumbsdown")
                            .foregroundColor(.black)
                    }

                    Button(action: onCommentTap) {
                        Label("\(post.comments.count)", systemImage: "message")
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
