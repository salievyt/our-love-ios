import Foundation

// MARK: - Daily Task Entity

struct DailyTask: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let isCompleted: Bool
    let completedAt: Date?
    let photoURL: String?
    let dateAssigned: Date
    let createdAt: Date
}
