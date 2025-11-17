import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AIChatView: View {
    
    @State private var userInput = ""
    @State private var messages: [Message] = [
        Message(text: "Hey there, how can I help you today?", isUser: false)
    ]
    
    @StateObject private var feedViewModel = FeedViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            
            VStack(spacing: 4) {
                Text("Ask UTD AI")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Get instant answers about campus events and activities")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)
            
            Divider()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { msg in
                            if msg.isUser {
                                userMessageView(msg)
                            } else {
                                aiMessageView(msg)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Ask me anything...", text: $userInput)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 45, height: 40)
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }
}

extension AIChatView {
    @ViewBuilder
    private func userMessageView(_ msg: Message) -> some View {
        HStack(alignment: .bottom) {
            Spacer()
            Text(msg.text)
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .frame(maxWidth: 250, alignment: .trailing)
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
                .padding(5)
                .background(Circle().fill(Color.gray.opacity(0.3)))
        }
    }
}

extension AIChatView {
    @ViewBuilder
    private func aiMessageView(_ msg: Message) -> some View {
        HStack(alignment: .bottom) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(.white)
                .padding(5)
                .background(Circle().fill(Color.black))
            
            Text(msg.text)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.black)
                .cornerRadius(12)
                .frame(maxWidth: 250, alignment: .leading)
            
            Spacer()
        }
    }
}

extension AIChatView {
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let question = userInput
        messages.append(Message(text: question, isUser: true))
        userInput = ""
        
        let systemPrompt = """
        You are a helpful fake AI chatbot for the University of Texas at Dallas (UTD).
        All events you describe are fictional but realistic.

        Rules:
        1. Make up plausible UTD event names, locations, and times.
        2. Keep responses conversational.
        3. Select one category from: Events, Sports, Arts, Technology, Music, General.
        4. End with: "Category: <name>"
        5. Limit responses to 150 words.
        """
        
        Task {
            do {
                let fullPrompt = "\(systemPrompt)\n\nUser Question: \"\(question)\""
                let reply = try await GeminiService.shared.sendMessage(fullPrompt)
                
                await MainActor.run {
                    messages.append(Message(text: reply, isUser: false))
                }
                
                let lines = reply.components(separatedBy: .newlines)
                let categoryLine = lines.first { $0.lowercased().starts(with: "category:") }
                let category = categoryLine?
                    .replacingOccurrences(of: "Category:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? "General"
                
                // Build Under-Review Post
                let newPost = PostModel(
                    id: nil,
                    username: "User",
                    category: category,
                    question: question,
                    aiResponse: reply,
                    likes: 0,
                    dislikes: 0,
                    comments: [],
                    timestamp: ""
                )
                
                await feedViewModel.addUnderReviewPost(newPost)
                
            } catch {
                await MainActor.run {
                    messages.append(Message(text: "Error: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
}

#Preview { AIChatView() }
