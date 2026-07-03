import Foundation

// MARK: - Capsule Use Case Protocol

protocol CapsuleUseCaseType {
    func fetchActiveCapsules() async throws -> PaginatedResponse<TimeCapsule>
    func fetchOpenedCapsules() async throws -> PaginatedResponse<TimeCapsule>
    func createCapsule(title: String, message: String, openDate: Date, photo: Data?, voiceNote: Data?) async throws -> TimeCapsule
    func openCapsule(id: String) async throws -> TimeCapsule
    func deleteCapsule(id: String) async throws
}

// MARK: - Capsule Use Case

final class CapsuleUseCase: CapsuleUseCaseType {
    
    private let capsuleRepo: CapsuleRepositoryProtocol
    
    init(capsuleRepo: CapsuleRepositoryProtocol) {
        self.capsuleRepo = capsuleRepo
    }
    
    func fetchActiveCapsules() async throws -> PaginatedResponse<TimeCapsule> {
        try await capsuleRepo.fetchActiveCapsules(page: nil, search: nil, ordering: nil)
    }
    
    func fetchOpenedCapsules() async throws -> PaginatedResponse<TimeCapsule> {
        try await capsuleRepo.fetchOpenedCapsules(page: nil, search: nil, ordering: nil)
    }
    
    func createCapsule(title: String, message: String, openDate: Date, photo: Data? = nil, voiceNote: Data? = nil) async throws -> TimeCapsule {
        try await capsuleRepo.createCapsule(
            title: title,
            message: message,
            openDate: openDate,
            photo: photo,
            voiceNote: voiceNote
        )
    }
    
    func openCapsule(id: String) async throws -> TimeCapsule {
        try await capsuleRepo.openCapsule(id: id)
    }
    
    func deleteCapsule(id: String) async throws {
        try await capsuleRepo.deleteCapsule(id: id)
    }
}
