import Foundation

// MARK: - Photo Entity

struct Photo: Identifiable, Equatable, Codable {
    let id: String
    let imageURL: String
    let image: String
    let caption: String?
    let createdAt: Date
    let yearTag: Int
    let latitude: Double?
    let longitude: Double?
}
