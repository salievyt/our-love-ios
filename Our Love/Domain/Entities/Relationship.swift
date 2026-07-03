import Foundation

// MARK: - Relationship Entity

struct Relationship: Identifiable, Equatable, Codable {
    let id: String
    let partner1: User
    let partner2: User?
    let partner1Name: String
    let partner2Name: String
    let partner1Emoji: String
    let partner2Emoji: String
    let startDate: Date
    let daysTogether: Int
}
