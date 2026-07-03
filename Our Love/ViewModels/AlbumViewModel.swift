import Foundation
import SwiftUI
import Combine

// MARK: - Album ViewModel

@MainActor
final class AlbumViewModel: ObservableObject {
    
    @Published var photos: [Photo] = []
    @Published var collages: [Collage] = []
    @Published var selectedYear: Int? = nil
    @Published var isLoading = false
    @Published var error: String?
    @Published var loadError: Error?
    
    private let albumUseCase: AlbumUseCaseType
    
    init(albumUseCase: AlbumUseCaseType) {
        self.albumUseCase = albumUseCase
    }
    
    var availableYears: [Int] {
        let years = Set(photos.compactMap { $0.yearTag })
        return Array(years).sorted(by: >)
    }
    
    var filteredPhotos: [Photo] {
        if let year = selectedYear {
            return photos.filter { $0.yearTag == year }
        }
        return photos
    }
    
    var isNetworkError: Bool {
        guard let error = loadError else { return false }
        if let apiError = error as? APIError {
            if case .networkError = apiError { return true }
            return false
        }
        return (error as NSError).domain == NSURLErrorDomain
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        loadError = nil
        
        do {
            async let photosResult = albumUseCase.fetchPhotos(page: nil, yearTag: nil, search: nil)
            async let collagesResult = albumUseCase.fetchCollages(page: nil, search: nil)
            
            let (photosResponse, collagesResponse) = try await (photosResult, collagesResult)
            self.photos = photosResponse.results
            self.collages = collagesResponse.results
        } catch {
            self.error = error.localizedDescription
            self.loadError = error
        }
        
        isLoading = false
    }
    
    func uploadPhoto(imageData: Data, caption: String?, latitude: Double? = nil, longitude: Double? = nil) async {
        do {
            _ = try await albumUseCase.uploadPhoto(
                imageData: imageData,
                caption: caption,
                latitude: latitude,
                longitude: longitude
            )
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func updatePhoto(id: String, caption: String) async {
        do {
            let normalizedCaption = caption.isEmpty ? nil : caption
            let updated = try await albumUseCase.updatePhoto(id: id, caption: normalizedCaption)
            if let index = photos.firstIndex(where: { $0.id == id }) {
                photos[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deletePhoto(id: String) async {
        do {
            try await albumUseCase.deletePhoto(id: id)
            photos.removeAll { $0.id == id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
