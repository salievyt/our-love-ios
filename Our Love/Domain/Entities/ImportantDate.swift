import Foundation

// MARK: - Important Date Entity

struct ImportantDate: Identifiable, Equatable, Codable {
    let id: String
    let relationshipID: String
    let title: String
    let date: Date
    let emoji: String
    let isAnnually: Bool
    let daysUntil: Int
    let createdAt: Date
}
