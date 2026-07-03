import Foundation

// MARK: - Task DTOs

struct DailyTaskDTO: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let isCompleted: Bool
    let completedAt: String?
    let photo: String?
    let photoURL: String
    let dateAssigned: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, emoji
        case description
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case photo
        case photoURL = "photo_url"
        case dateAssigned = "date_assigned"
        case createdAt = "created_at"
    }
}

struct TaskTemplateDTO: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let emoji: String
}
