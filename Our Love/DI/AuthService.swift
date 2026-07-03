import Foundation
import Combine

// MARK: - Auth Service Protocol

@MainActor
protocol AuthServiceType: ObservableObject where Self: AnyObject {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    var relationship: Relationship? { get }
    var isLoading: Bool { get }
    var error: String? { get }
    
    func login(username: String, password: String) async
    func register(username: String, password: String, email: String, inviteCode: String?) async
    func logout() async
    func fetchProfile() async
    func generateInviteCode() async -> String?
}

// MARK: - Auth Service Implementation

@MainActor
final class AuthServiceImpl: AuthServiceType {
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var relationship: Relationship? = nil
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let authRepo: AuthRepositoryProtocol
    
    init(authRepo: AuthRepositoryProtocol) {
        self.authRepo = authRepo
        self.isAuthenticated = authRepo.isAuthenticated
        if isAuthenticated {
            Task { await fetchProfile() }
        }
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            try await authRepo.login(username: username, password: password)
            isAuthenticated = true
            currentUser = authRepo.currentUser
            relationship = authRepo.relationship
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register(username: String, password: String, email: String, inviteCode: String?) async {
        isLoading = true
        error = nil
        
        do {
            try await authRepo.register(
                username: username,
                password: password,
                email: email,
                inviteCode: inviteCode
            )
            isAuthenticated = true
            currentUser = authRepo.currentUser
            relationship = authRepo.relationship
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        do {
            try await authRepo.logout()
        } catch {
            // Ignore logout errors
        }
        isAuthenticated = false
        currentUser = nil
        relationship = nil
    }
    
    func fetchProfile() async {
        do {
            try await authRepo.fetchProfile()
            currentUser = authRepo.currentUser
            relationship = authRepo.relationship
        } catch {
            if case APIError.unauthorized = error {
                isAuthenticated = false
                currentUser = nil
                relationship = nil
            }
            self.error = error.localizedDescription
        }
    }
    
    func generateInviteCode() async -> String? {
        isLoading = true
        defer { isLoading = false }
        do {
            let code = try await authRepo.generateInviteCode()
            return code
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
}
