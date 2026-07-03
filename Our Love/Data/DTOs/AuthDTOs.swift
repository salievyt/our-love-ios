import Foundation

// MARK: - Auth DTOs

struct LoginRequestDTO: Codable {
    let username: String
    let password: String
}

struct TokenResponseDTO: Codable {
    let access: String
    let refresh: String
}

struct RegisterRequestDTO: Codable {
    let username: String
    let password: String
    let email: String
    let inviteCode: String?
    
    enum CodingKeys: String, CodingKey {
        case username, password, email
        case inviteCode = "invite_code"
    }
}

struct LogoutRequestDTO: Codable {
    let refresh: String
}

struct UserProfileDTO: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar, phone
    }
}

struct RelationshipDTO: Codable {
    let id: String
    let partner1: UserProfileDTO
    let partner2: UserProfileDTO?
    let partner1Name: String
    let partner2Name: String
    let partner1Emoji: String
    let partner2Emoji: String
    let relationshipStartDate: String
    let daysTogether: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case partner1, partner2
        case partner1Name = "partner1_name"
        case partner2Name = "partner2_name"
        case partner1Emoji = "partner1_emoji"
        case partner2Emoji = "partner2_emoji"
        case relationshipStartDate = "relationship_start_date"
        case daysTogether = "days_together"
        case createdAt = "created_at"
    }
}

struct InviteCodeResponseDTO: Codable {
    let id: String
    let code: String
    let isUsed: Bool
    let createdAt: String
    let expiresAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case isUsed = "is_used"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}
