import Foundation

// MARK: - Mood Repository Protocol

protocol MoodRepositoryProtocol {
    func fetchTodayMood() async throws -> MoodEntry?
    func fetchMoods(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<MoodEntry>
    func fetchMood(id: String) async throws -> MoodEntry
    func createMood(mood: Mood, note: String?, date: Date) async throws -> MoodEntry
    func updateMood(id: String, mood: Mood, note: String?, date: Date) async throws -> MoodEntry
    func deleteMood(id: String) async throws
    func fetchMoodStats() async throws -> MoodStats
}
