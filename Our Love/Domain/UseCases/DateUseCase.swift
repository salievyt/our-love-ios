import Foundation

// MARK: - Date Use Case Protocol

protocol DateUseCaseType {
    func fetchUpcomingDates() async throws -> PaginatedResponse<ImportantDate>
    func fetchAllDates() async throws -> PaginatedResponse<ImportantDate>
    func createDate(title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate
    func deleteDate(id: String) async throws
}

// MARK: - Date Use Case

final class DateUseCase: DateUseCaseType {
    
    private let dateRepo: DateRepositoryProtocol
    
    init(dateRepo: DateRepositoryProtocol) {
        self.dateRepo = dateRepo
    }
    
    func fetchUpcomingDates() async throws -> PaginatedResponse<ImportantDate> {
        try await dateRepo.fetchUpcomingDates(page: nil, search: nil, ordering: nil)
    }
    
    func fetchAllDates() async throws -> PaginatedResponse<ImportantDate> {
        try await dateRepo.fetchDates(isAnnually: nil, page: nil, search: nil, ordering: nil)
    }
    
    func createDate(title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate {
        try await dateRepo.createDate(title: title, date: date, emoji: emoji, isAnnually: isAnnually)
    }
    
    func deleteDate(id: String) async throws {
        try await dateRepo.deleteDate(id: id)
    }
}
