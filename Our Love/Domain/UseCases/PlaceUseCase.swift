import Foundation

// MARK: - Place Use Case Protocol

protocol PlaceUseCaseType {
    func fetchPlaces() async throws -> PaginatedResponse<Place>
    func createPlace(title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data?) async throws -> Place
    func deletePlace(id: String) async throws
}

// MARK: - Place Use Case

final class PlaceUseCase: PlaceUseCaseType {
    
    private let placeRepo: PlaceRepositoryProtocol
    
    init(placeRepo: PlaceRepositoryProtocol) {
        self.placeRepo = placeRepo
    }
    
    func fetchPlaces() async throws -> PaginatedResponse<Place> {
        try await placeRepo.fetchPlaces(page: nil, search: nil, ordering: nil)
    }
    
    func createPlace(title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data? = nil) async throws -> Place {
        try await placeRepo.createPlace(
            title: title,
            description: description,
            emoji: emoji,
            latitude: latitude,
            longitude: longitude,
            photo: photo
        )
    }
    
    func deletePlace(id: String) async throws {
        try await placeRepo.deletePlace(id: id)
    }
}
