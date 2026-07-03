import Foundation

// MARK: - Mood Entry Entity

struct MoodEntry: Identifiable, Equatable, Codable {
    let id: String
    let userID: String
    let mood: Mood
    let note: String?
    let date: Date
    let createdAt: Date
}
