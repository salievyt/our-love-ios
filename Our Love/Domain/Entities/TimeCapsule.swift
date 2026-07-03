import Foundation

// MARK: - Time Capsule Entity

struct TimeCapsule: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let message: String
    let photoURL: String?
    let voiceNoteURL: String?
    let openDate: Date
    let isOpened: Bool
    let isReadyToOpen: Bool
    let daysUntilOpen: Int
    let openedAt: Date?
    let createdAt: Date
}
