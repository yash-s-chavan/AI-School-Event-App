import Foundation


extension String {
    func timeAgo() -> String {
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: self)
        
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: self)
        }
        
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            fallback.locale = Locale(identifier: "en_US_POSIX")
            date = fallback.date(from: self)
        }
        
        guard let date else { return "unknown" }
        
        let secondsAgo = Int(Date().timeIntervalSince(date))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        if secondsAgo < minute { return "just now" }
        if secondsAgo < hour { return "\(secondsAgo / minute)m ago" }
        if secondsAgo < day { return "\(secondsAgo / hour)h ago" }
        
        return "\(secondsAgo / day)d ago"
    }
}
