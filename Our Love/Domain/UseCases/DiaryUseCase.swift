import Foundation

// MARK: - Diary Use Case Protocol

protocol DiaryUseCaseType {
    func fetchEntries(date: Date?) async throws -> PaginatedResponse<DiaryEntry>
    func fetchTodayEntry() async throws -> DiaryEntry?
    func createEntry(date: Date, note: String?, photo: Data?, moodPartner1: Int?) async throws -> DiaryEntry
    func deleteEntry(id: String) async throws
}

// MARK: - Diary Use Case

final class DiaryUseCase: DiaryUseCaseType {
    
    private let diaryRepo: DiaryRepositoryProtocol
    
    init(diaryRepo: DiaryRepositoryProtocol) {
        self.diaryRepo = diaryRepo
    }
    
    func fetchEntries(date: Date? = nil) async throws -> PaginatedResponse<DiaryEntry> {
        try await diaryRepo.fetchEntries(
            date: date,
            page: nil,
            search: nil,
            ordering: nil
        )
    }
    
    func fetchTodayEntry() async throws -> DiaryEntry? {
        try await diaryRepo.fetchTodayEntry()
    }
    
    func createEntry(date: Date, note: String?, photo: Data?, moodPartner1: Int?) async throws -> DiaryEntry {
        try await diaryRepo.createEntry(date: date, note: note, photo: photo, moodPartner1: moodPartner1)
    }
    
    func deleteEntry(id: String) async throws {
        try await diaryRepo.deleteEntry(id: id)
    }
}
