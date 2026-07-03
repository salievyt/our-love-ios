import Foundation

// MARK: - Album Repository Protocol

protocol AlbumRepositoryProtocol {
    func fetchPhotos(page: Int?, yearTag: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Photo>
    func fetchPhoto(id: String) async throws -> Photo
    func uploadPhoto(imageData: Data, caption: String?, latitude: Double?, longitude: Double?) async throws -> Photo
    func updatePhoto(id: String, caption: String?, imageData: Data?) async throws -> Photo
    func deletePhoto(id: String) async throws
    func fetchCollages(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Collage>
    func createCollage(title: String, photoIDs: [String]) async throws -> Collage
    func deleteCollage(id: String) async throws
}
