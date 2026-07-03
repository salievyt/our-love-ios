import Foundation

// MARK: - Collage Entity

struct Collage: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let imageURL: String?
    let photoIDs: [String]
    let photoCount: Int
    let createdAt: Date
}
