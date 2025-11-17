import Foundation


class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey: String
    private let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    private init() {
        guard
            let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict["GEMINI_API_KEY"] as? String
        else {
            fatalError("Failed to load Gemini API key from Secrets.plist")
        }
        
        self.apiKey = key
    }
    
    func sendMessage(_ message: String) async throws -> String {
        struct GeminiResponse: Codable {
            struct Candidate: Codable {
                struct Content: Codable {
                    struct Part: Codable {
                        let text: String?
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": message]
                    ]
                ]
            ]
        ]
        
        var components = URLComponents(string: endpoint)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "GeminiService",
                code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
        
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return decoded.candidates.first?.content.parts.first?.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "No response from Gemini"
    }
}
