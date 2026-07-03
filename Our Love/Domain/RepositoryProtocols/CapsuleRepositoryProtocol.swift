import Foundation

// MARK: - Capsule Repository Protocol

protocol CapsuleRepositoryProtocol {
    func fetchActiveCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule>
    func fetchOpenedCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule>
    func fetchCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule>
    func fetchCapsule(id: String) async throws -> TimeCapsule
    func createCapsule(title: String, message: String, openDate: Date, photo: Data?, voiceNote: Data?) async throws -> TimeCapsule
    func updateCapsule(id: String, title: String, message: String, openDate: Date, photo: Data?, voiceNote: Data?) async throws -> TimeCapsule
    func openCapsule(id: String) async throws -> TimeCapsule
    func deleteCapsule(id: String) async throws
}
