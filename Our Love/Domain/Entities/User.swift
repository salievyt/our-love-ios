import Foundation

// MARK: - User Entity

struct User: Identifiable, Equatable, Codable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let avatarURL: String?
    let phone: String?
}
