import Foundation

// MARK: - Partner Like Entities

struct PartnerLikeResponse: Codable {
    let like: PartnerLike
    let isMatch: Bool

    enum CodingKeys: String, CodingKey {
        case like
        case isMatch = "is_match"
    }
}

struct PartnerLike: Identifiable, Codable {
    let id: String
    let toUser: String
    let isLike: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case toUser = "to_user"
        case isLike = "is_like"
        case createdAt = "created_at"
    }
}
