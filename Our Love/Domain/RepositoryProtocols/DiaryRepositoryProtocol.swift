import Foundation

// MARK: - Diary Repository Protocol

protocol DiaryRepositoryProtocol {
    func fetchEntries(date: Date?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<DiaryEntry>
    func fetchTodayEntry() async throws -> DiaryEntry?
    func fetchEntry(id: String) async throws -> DiaryEntry
    func createEntry(date: Date, note: String?, photo: Data?, moodPartner1: Int?) async throws -> DiaryEntry
    func updateEntry(id: String, note: String?, photo: Data?, moodPartner1: Int?, moodPartner2: Int?, questionAnswerPartner1: String?, questionAnswerPartner2: String?) async throws -> DiaryEntry
    func deleteEntry(id: String) async throws
}
