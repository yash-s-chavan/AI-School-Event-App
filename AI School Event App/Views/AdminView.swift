import SwiftUI

struct AdminView: View {
    
    @State private var loggedIn = false
    @State private var password = ""
    @State private var postCount = 0
    
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        if loggedIn {
            
            VStack(spacing: 12) {
                
                AdminHeaderView()
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Pending Approval")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("\(postCount)")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal)
                .task {
                    if let count = await fetchPostCount() {
                        postCount = count
                    }
                }
                
                Divider()
                
                AdminUnderReviewList(
                    viewModel: viewModel,
                    postCount: $postCount
                )
                .task {
                    await viewModel.fetchUnderReview()
                }
            }
            
        } else {
            
            VStack {
                Spacer()
                
                Image(systemName: "shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding(.top)
                
                Text("Confirm Access")
                Text("Re-enter your admin password to continue")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Admin Password")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                TextField("Enter your password", text: $password)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button {
                    Task {
                        loggedIn = await checkPassword(password)
                    }
                } label: {
                    HStack {
                        Image(systemName: "lock")
                        Text("Confirm")
                    }
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.black)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(maxWidth: 300, maxHeight: 250)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
    
    private func checkPassword(_ password: String) async -> Bool {
        guard let url = URL(string: "http://localhost:8080/passwords/login") else { return false }
        
        let body = ["password": password]
        guard let encoded = try? JSONEncoder().encode(body) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return result == "success"
        } catch {
            return false
        }
    }
    
    private func fetchPostCount() async -> Int? {
        guard let url = URL(string: "http://localhost:8080/posts/underreview/count") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return Int(String(decoding: data, as: UTF8.self))
        } catch {
            return nil
        }
    }
}


struct AdminHeaderView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Admin Moderation Panel")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Review pending posts")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 8)
    }
}

#Preview {
    AdminView()
}
