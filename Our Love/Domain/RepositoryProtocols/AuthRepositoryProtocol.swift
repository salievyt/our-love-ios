import Foundation

// MARK: - Auth Repository Protocol

protocol AuthRepositoryProtocol {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    var relationship: Relationship? { get }
    
    func login(username: String, password: String) async throws
    func register(username: String, password: String, email: String, inviteCode: String?) async throws
    func logout() async throws
    func fetchProfile() async throws
    func generateInviteCode() async throws -> String
    func refreshTokens() async throws
}
