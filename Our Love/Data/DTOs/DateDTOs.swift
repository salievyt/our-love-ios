import Foundation

// MARK: - Important Date DTOs

struct ImportantDateDTO: Codable, Identifiable {
    let id: String
    let relationship: String
    let title: String
    let date: String
    let emoji: String
    let isAnnually: Bool
    let daysUntil: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, relationship, title, date, emoji
        case isAnnually = "is_annually"
        case daysUntil = "days_until"
        case createdAt = "created_at"
    }
}
