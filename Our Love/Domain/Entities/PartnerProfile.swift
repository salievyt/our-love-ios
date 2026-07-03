import Foundation

// MARK: - Partner Profile Entity

struct PartnerProfile: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let bio: String?
    let city: String?
    let birthDate: String?
    let age: Int?
    let gender: String?
    let photo: String?
    let isActive: Bool
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case bio
        case city
        case birthDate = "birth_date"
        case age
        case gender
        case photo
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
