import Foundation


struct PostModel: Identifiable, Codable {
    var id: String?
    var username: String
    var category: String
    var question: String
    var aiResponse: String
    var likes: Int
    var dislikes: Int
    var comments: [String]
    var timestamp: String?
}


class FeedViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    @Published var underReviewPosts: [PostModel] = []
    
    private let baseURL = "http://localhost:8080"
    
    
    func fetchPosts(sortedBy: String = "Relevant") async {
        guard let url = URL(string: "\(baseURL)/posts") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([PostModel].self, from: data)
            let sorted = sortPosts(decoded, by: sortedBy)
            
            await MainActor.run {
                self.posts = sorted
            }
        } catch { }
    }
    
    private func sortPosts(_ posts: [PostModel], by mode: String) -> [PostModel] {
        switch mode {
        case "Recent":
            return posts.sorted { a, b in
                (a.timestamp ?? "") > (b.timestamp ?? "")
            }
        case "Top":
            return posts.sorted { a, b in
                let scoreA = a.likes + a.comments.count
                let scoreB = b.likes + b.comments.count
                return scoreA > scoreB
            }
        default:
            return posts.sorted { a, b in
                let scoreA = a.likes - a.dislikes
                let scoreB = b.likes - b.dislikes
                return scoreA > scoreB
            }
        }
    }
    
    
    func updateReaction(postId: String, type: String) async {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/reaction") else { return }
        
        let body = ["type": type]
        guard let json = try? JSONEncoder().encode(body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        do {
            _ = try await URLSession.shared.data(for: request)
            await fetchPosts()
        } catch { }
    }
    
    func postComment(postId: String, content: String) async {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/comment") else { return }
        
        let body = ["comment": content]
        guard let jsonData = try? JSONEncoder().encode(body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            _ = try await URLSession.shared.data(for: request)
            await fetchPosts()
        } catch { }
    }
    
    
    func fetchUnderReview() async {
        guard let url = URL(string: "\(baseURL)/posts/admin/under-review") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([PostModel].self, from: data)
            
            await MainActor.run {
                self.underReviewPosts = decoded
            }
        } catch { }
    }
    
    func addUnderReviewPost(_ post: PostModel) async {
        guard let url = URL(string: "\(baseURL)/posts/underReview") else { return }
        
        do {
            let encoded = try JSONEncoder().encode(post)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = encoded
            
            _ = try await URLSession.shared.data(for: request)
        } catch { }
    }
    
    func approvePost(postId: String) async {
        guard let url = URL(string: "\(baseURL)/posts/admin/approve/\(postId)") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            _ = try await URLSession.shared.data(for: request)
        } catch { }
    }
    
    func rejectPost(postId: String) async {
        guard let url = URL(string: "\(baseURL)/posts/admin/reject/\(postId)") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            _ = try await URLSession.shared.data(for: request)
        } catch { }
    }
    
    func fetchUnderReviewCount() async -> Int? {
        guard let url = URL(string: "\(baseURL)/posts/underreview/count") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return Int(String(decoding: data, as: UTF8.self))
        } catch {
            return nil
        }
    }
}
