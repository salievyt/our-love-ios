import Foundation
import SwiftUI
import Combine

// MARK: - Partner Search ViewModel

@MainActor
final class PartnerSearchViewModel: ObservableObject {
    
    @Published var profiles: [PartnerProfile] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var isSearching = false
    @Published var matchProfile: PartnerProfile?
    @Published var showingMatch = false
    @Published var matches: [PartnerProfile] = []
    
    // Filters
    @Published var filterCity: String = ""
    @Published var filterGender: String = ""
    
    private let partnerAPI: PartnerAPI
    
    var currentProfile: PartnerProfile? {
        guard currentIndex < profiles.count else { return nil }
        return profiles[currentIndex]
    }
    
    init(partnerAPI: PartnerAPI = PartnerAPI()) {
        self.partnerAPI = partnerAPI
    }
    
    func loadProfiles() async {
        isSearching = true
        error = nil
        
        do {
            profiles = try await partnerAPI.searchProfiles(
                city: filterCity.isEmpty ? nil : filterCity,
                gender: filterGender.isEmpty ? nil : filterGender
            )
            currentIndex = 0
        } catch {
            self.error = error.localizedDescription
        }
        
        isSearching = false
    }
    
    func likeCurrentProfile() async {
        guard let profile = currentProfile else { return }
        
        do {
            let response = try await partnerAPI.likeProfile(toUserId: profile.id, isLike: true)
            if response.isMatch {
                matchProfile = profile
                showingMatch = true
            }
            moveNext()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func passCurrentProfile() async {
        guard let profile = currentProfile else { return }
        
        do {
            _ = try await partnerAPI.likeProfile(toUserId: profile.id, isLike: false)
            moveNext()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func moveNext() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentIndex += 1
        }
        if currentIndex >= profiles.count {
            profiles = []
            currentIndex = 0
        }
    }
    
    func loadMatches() async {
        do {
            matches = try await partnerAPI.getMatches()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func dismissMatch() {
        showingMatch = false
        matchProfile = nil
        if profiles.isEmpty {
            Task { await loadProfiles() }
        }
    }
}
