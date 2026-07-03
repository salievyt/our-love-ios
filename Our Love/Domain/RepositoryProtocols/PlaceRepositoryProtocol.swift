import Foundation

// MARK: - Place Repository Protocol

protocol PlaceRepositoryProtocol {
    func fetchPlaces(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Place>
    func fetchPlace(id: String) async throws -> Place
    func createPlace(title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data?) async throws -> Place
    func updatePlace(id: String, title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data?) async throws -> Place
    func deletePlace(id: String) async throws
}
