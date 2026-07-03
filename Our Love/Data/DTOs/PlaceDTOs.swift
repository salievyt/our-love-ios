import Foundation

// MARK: - Place DTOs

struct PlaceDTO: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let latitude: Double
    let longitude: Double
    let photo: String?
    let photoURL: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, latitude, longitude, photo
        case photoURL = "photo_url"
        case createdAt = "created_at"
    }
}
