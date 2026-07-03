import Foundation

// MARK: - Answer Entity

struct Answer: Identifiable, Equatable, Codable {
    let id: String
    let questionID: String
    let user: String
    let text: String
    let createdAt: Date
}
