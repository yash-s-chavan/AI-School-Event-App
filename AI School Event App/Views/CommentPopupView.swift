import SwiftUI

struct CommentPopupView: View {
    let comments: [String]
    @Binding var newComment: String
    let onClose: () -> Void
    let onPost: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if comments.isEmpty {
                        Text("No comments yet. Be the first to comment!")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.top, 10)
                    } else {
                        ForEach(comments, id: \.self) { c in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("CurrentUser:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(c)
                                    .font(.subheadline)
                                Divider()
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: 220)

            Divider()

            HStack {
                TextField("Write a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Post", action: onPost)
                    .buttonStyle(.borderedProminent)
                    .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.bottom, 40)
    }
}
