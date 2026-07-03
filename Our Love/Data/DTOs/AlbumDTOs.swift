import Foundation

// MARK: - Album DTOs

struct PhotoDTO: Codable, Identifiable {
    let id: String
    let image: String
    let imageURL: String
    let caption: String?
    let createdAt: String
    let yearTag: Int
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, image
        case imageURL = "image_url"
        case caption
        case createdAt = "created_at"
        case yearTag = "year_tag"
        case latitude, longitude
    }
}

struct CollageDTO: Codable, Identifiable {
    let id: String
    let title: String
    let image: String?
    let imageURL: String?
    let photos: [String]
    let photoCount: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, image
        case imageURL = "image_url"
        case photos
        case photoCount = "photo_count"
        case createdAt = "created_at"
    }
}
