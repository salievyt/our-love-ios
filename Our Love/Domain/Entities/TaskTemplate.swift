import Foundation

// MARK: - Task Template Entity

struct TaskTemplate: Identifiable, Equatable, Codable {
    let id: Int
    let title: String
    let description: String
    let emoji: String
}
