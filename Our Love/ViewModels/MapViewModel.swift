import Foundation
import SwiftUI
import Combine

// MARK: - Map ViewModel

@MainActor
final class MapViewModel: ObservableObject {
    
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let placeUseCase: PlaceUseCaseType
    
    init(placeUseCase: PlaceUseCaseType) {
        self.placeUseCase = placeUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await placeUseCase.fetchPlaces()
            self.places = response.results
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addPlace(title: String, description: String, emoji: String, latitude: Double, longitude: Double) async {
        do {
            _ = try await placeUseCase.createPlace(
                title: title,
                description: description,
                emoji: emoji,
                latitude: latitude,
                longitude: longitude,
                photo: nil
            )
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deletePlace(id: String) async {
        do {
            try await placeUseCase.deletePlace(id: id)
            places.removeAll { $0.id == id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
