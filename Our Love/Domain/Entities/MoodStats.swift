import Foundation

// MARK: - Mood Stats Entity

struct MoodStats: Codable {
    let totalEntries: Int
    let averageMood: Double
    let streak: Int
    let distribution: [Mood: Int]
}
