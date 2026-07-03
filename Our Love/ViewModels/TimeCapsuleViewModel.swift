import Foundation
import SwiftUI
import Combine

// MARK: - Time Capsule ViewModel

@MainActor
final class TimeCapsuleViewModel: ObservableObject {
    
    @Published var activeCapsules: [TimeCapsule] = []
    @Published var openedCapsules: [TimeCapsule] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showingCreateSheet = false
    
    private let capsuleUseCase: CapsuleUseCaseType
    
    init(capsuleUseCase: CapsuleUseCaseType) {
        self.capsuleUseCase = capsuleUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            async let activeResult = capsuleUseCase.fetchActiveCapsules()
            async let openedResult = capsuleUseCase.fetchOpenedCapsules()
            
            let (active, opened) = try await (activeResult, openedResult)
            self.activeCapsules = active.results
            self.openedCapsules = opened.results
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createCapsule(title: String, message: String, openDate: Date) async {
        do {
            _ = try await capsuleUseCase.createCapsule(title: title, message: message, openDate: openDate, photo: nil, voiceNote: nil)
            showingCreateSheet = false
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func openCapsule(id: String) async {
        do {
            _ = try await capsuleUseCase.openCapsule(id: id)
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
