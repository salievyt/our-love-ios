import Foundation

// MARK: - Diary DTOs

struct DiaryEntryDTO: Codable, Identifiable {
    let id: String
    let date: String
    let note: String?
    let photo: String?
    let photoURL: String
    let moodPartner1: Int?
    let moodPartner2: Int?
    let questionAnswerPartner1: String?
    let questionAnswerPartner2: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, note, photo
        case photoURL = "photo_url"
        case moodPartner1 = "mood_partner1"
        case moodPartner2 = "mood_partner2"
        case questionAnswerPartner1 = "question_answer_partner1"
        case questionAnswerPartner2 = "question_answer_partner2"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
