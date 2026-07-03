import Foundation

// MARK: - Album Use Case Protocol

protocol AlbumUseCaseType {
    func fetchPhotos(page: Int?, yearTag: Int?, search: String?) async throws -> PaginatedResponse<Photo>
    func uploadPhoto(imageData: Data, caption: String?, latitude: Double?, longitude: Double?) async throws -> Photo
    func updatePhoto(id: String, caption: String?) async throws -> Photo
    func deletePhoto(id: String) async throws
    func fetchCollages(page: Int?, search: String?) async throws -> PaginatedResponse<Collage>
}

// MARK: - Album Use Case

final class AlbumUseCase: AlbumUseCaseType {
    
    private let albumRepo: AlbumRepositoryProtocol
    
    init(albumRepo: AlbumRepositoryProtocol) {
        self.albumRepo = albumRepo
    }
    
    func fetchPhotos(page: Int?, yearTag: Int?, search: String?) async throws -> PaginatedResponse<Photo> {
        try await albumRepo.fetchPhotos(page: page, yearTag: yearTag, search: search, ordering: nil)
    }
    
    func uploadPhoto(imageData: Data, caption: String?, latitude: Double?, longitude: Double?) async throws -> Photo {
        try await albumRepo.uploadPhoto(imageData: imageData, caption: caption, latitude: latitude, longitude: longitude)
    }
    
    func updatePhoto(id: String, caption: String?) async throws -> Photo {
        try await albumRepo.updatePhoto(id: id, caption: caption, imageData: nil)
    }
    
    func deletePhoto(id: String) async throws {
        try await albumRepo.deletePhoto(id: id)
    }
    
    func fetchCollages(page: Int?, search: String?) async throws -> PaginatedResponse<Collage> {
        try await albumRepo.fetchCollages(page: page, search: search, ordering: nil)
    }
}
