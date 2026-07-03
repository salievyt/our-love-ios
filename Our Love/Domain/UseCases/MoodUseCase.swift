import Foundation

// MARK: - Mood Use Case Protocol

protocol MoodUseCaseType {
    func fetchTodayMood() async throws -> MoodEntry?
    func fetchMoods() async throws -> PaginatedResponse<MoodEntry>
    func saveMood(mood: Mood, note: String?, date: Date) async throws -> MoodEntry
    func fetchMoodStats() async throws -> MoodStats
}

// MARK: - Mood Use Case

final class MoodUseCase: MoodUseCaseType {
    
    private let moodRepo: MoodRepositoryProtocol
    
    init(moodRepo: MoodRepositoryProtocol) {
        self.moodRepo = moodRepo
    }
    
    func fetchTodayMood() async throws -> MoodEntry? {
        try await moodRepo.fetchTodayMood()
    }
    
    func fetchMoods() async throws -> PaginatedResponse<MoodEntry> {
        try await moodRepo.fetchMoods(page: nil, search: nil, ordering: nil)
    }
    
    func saveMood(mood: Mood, note: String?, date: Date) async throws -> MoodEntry {
        try await moodRepo.createMood(mood: mood, note: note, date: date)
    }
    
    func fetchMoodStats() async throws -> MoodStats {
        try await moodRepo.fetchMoodStats()
    }
}
