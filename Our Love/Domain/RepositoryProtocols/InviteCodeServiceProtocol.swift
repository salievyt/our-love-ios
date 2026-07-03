import Foundation

// MARK: - Auth Service Protocol (for invite code flow)

protocol InviteCodeServiceProtocol {
    func generateInviteCode() async throws -> String
    func acceptInviteCode(_ code: String) async throws
}
