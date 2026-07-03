import Foundation

// MARK: - Time Capsule DTOs

struct TimeCapsuleDTO: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let photo: String?
    let photoURL: String
    let voiceNote: String?
    let voiceNoteURL: String
    let openDate: String
    let isOpened: Bool
    let isReadyToOpen: Bool
    let daysUntilOpen: String
    let openedAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, photo
        case photoURL = "photo_url"
        case voiceNote = "voice_note"
        case voiceNoteURL = "voice_note_url"
        case openDate = "open_date"
        case isOpened = "is_opened"
        case isReadyToOpen = "is_ready_to_open"
        case daysUntilOpen = "days_until_open"
        case openedAt = "opened_at"
        case createdAt = "created_at"
    }
}

struct TimeCapsuleOpenDTO: Codable {
    let confirm: Bool
}
