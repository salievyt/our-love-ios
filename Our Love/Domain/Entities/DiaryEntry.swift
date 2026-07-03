import Foundation

// MARK: - Diary Entry Entity

struct DiaryEntry: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    let note: String?
    let photoURL: String?
    let moodPartner1: Int?
    let moodPartner2: Int?
    let questionAnswerPartner1: String?
    let questionAnswerPartner2: String?
    let createdAt: Date
    let updatedAt: Date
}
