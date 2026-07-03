import Foundation

// MARK: - Place Entity

struct Place: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let latitude: Double
    let longitude: Double
    let photoURL: String?
    let createdAt: Date
}
