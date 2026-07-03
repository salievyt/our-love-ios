import Foundation
import SwiftUI
import Combine

// MARK: - Poster Generator ViewModel

@MainActor
final class PosterGeneratorViewModel: ObservableObject {
    
    @Published var photos: [Photo] = []
    @Published var collages: [Collage] = []
    @Published var generatedPosters: [GeneratedPoster] = []
    @Published var selectedPhoto: Photo?
    @Published var isLoading = false
    @Published var error: String?
    
    private let albumUseCase: AlbumUseCaseType
    private let authService: any AuthServiceType
    
    init(albumUseCase: AlbumUseCaseType, authService: any AuthServiceType) {
        self.albumUseCase = albumUseCase
        self.authService = authService
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            async let photosResult = albumUseCase.fetchPhotos(page: nil, yearTag: nil, search: nil)
            async let collagesResult = albumUseCase.fetchCollages(page: nil, search: nil)
            
            let (photosResponse, collagesResponse) = try await (photosResult, collagesResult)
            self.photos = photosResponse.results
            self.collages = collagesResponse.results
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func generatePoster(template: PosterTemplate) async {
        isLoading = true
        error = nil
        
        await Task.yield()
        let poster = GeneratedPoster(template: template, createdAt: Date())
        generatedPosters.append(poster)
        isLoading = false
    }
    
    var daysTogether: Int {
        if let rel = authService.relationship {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: rel.startDate, to: Date())
            return max(components.day ?? 0, 0)
        }
        return 0
    }
}

// MARK: - Poster Template

enum PosterTemplate: String, CaseIterable, Identifiable {
    case romantic
    case adventure
    case funny
    case minimal
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .romantic: return "Романтика"
        case .adventure: return "Приключение"
        case .funny: return "Весёлый"
        case .minimal: return "Минимализм"
        }
    }
    
    var icon: String {
        switch self {
        case .romantic: return "heart.fill"
        case .adventure: return "sun.horizon.fill"
        case .funny: return "face.smiling.fill"
        case .minimal: return "sparkles"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .romantic: return .pink
        case .adventure: return .orange
        case .funny: return .yellow
        case .minimal: return .white
        }
    }
    
    var colors: [Color] {
        switch self {
        case .romantic: return [.pink.opacity(0.8), .purple.opacity(0.8)]
        case .adventure: return [.orange.opacity(0.8), .red.opacity(0.8)]
        case .funny: return [.yellow.opacity(0.8), .orange.opacity(0.8)]
        case .minimal: return [.gray.opacity(0.6), .white]
        }
    }
}

struct GeneratedPoster: Identifiable {
    let id = UUID()
    let template: PosterTemplate
    let createdAt: Date
}
