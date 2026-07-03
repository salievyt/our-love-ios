import Foundation

// MARK: - Mood DTOs

struct MoodEntryDTO: Codable, Identifiable {
    let id: String
    let user: String
    let mood: Int
    let note: String?
    let date: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, user, mood, note, date
        case createdAt = "created_at"
    }
}

struct MoodStatsDTO: Codable {
    let totalEntries: Int
    let averageMood: Double
    let streak: Int
    let distribution: [Int: Int]
    
    enum CodingKeys: String, CodingKey {
        case totalEntries = "total_entries"
        case averageMood = "average_mood"
        case streak
        case distribution
    }
}
