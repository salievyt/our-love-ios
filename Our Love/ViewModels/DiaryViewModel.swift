import Foundation
import SwiftUI
import Combine

// MARK: - Diary ViewModel

@MainActor
final class DiaryViewModel: ObservableObject {
    
    @Published var entries: [DiaryEntry] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var loadError: Error?
    
    private let diaryUseCase: DiaryUseCaseType
    
    init(diaryUseCase: DiaryUseCaseType) {
        self.diaryUseCase = diaryUseCase
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
            let response = try await diaryUseCase.fetchEntries(date: nil)
            self.entries = response.results
        } catch {
            self.error = error.localizedDescription
            self.loadError = error
        }
        
        isLoading = false
    }
}
