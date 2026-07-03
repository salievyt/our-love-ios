import Foundation

// MARK: - Date Repository Protocol

protocol DateRepositoryProtocol {
    func fetchDates(isAnnually: Bool?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<ImportantDate>
    func fetchUpcomingDates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<ImportantDate>
    func fetchDate(id: String) async throws -> ImportantDate
    func createDate(title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate
    func updateDate(id: String, title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate
    func deleteDate(id: String) async throws
}
