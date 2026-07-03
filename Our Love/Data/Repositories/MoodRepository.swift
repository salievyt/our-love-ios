import Foundation

// MARK: - Mood Repository Implementation

final class MoodRepository: MoodRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Today Mood
    
    func fetchTodayMood() async throws -> MoodEntry? {
        do {
            let dto: MoodEntryDTO = try await apiClient.request(path: "/moods/today/")
            return DataMapper.toDomain(dto)
        } catch {
            return nil
        }
    }
    
    // MARK: - Fetch Moods
    
    func fetchMoods(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<MoodEntry> {
        var path = "/moods/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<MoodEntryDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<MoodEntry>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Mood by ID
    
    func fetchMood(id: String) async throws -> MoodEntry {
        let dto: MoodEntryDTO = try await apiClient.request(path: "/moods/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Mood
    
    func createMood(mood: Mood, note: String?, date: Date) async throws -> MoodEntry {
        var body: [String: Any] = [
            "mood": mood.rawValue,
            "date": DataMapper.formatDateOnly(date)
        ]
        if let note = note { body["note"] = note }
        
        let data = try JSONSerialization.data(withJSONObject: body)
        let dto: MoodEntryDTO = try await apiClient.request(
            path: "/moods/",
            method: HTTPMethod.post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Mood
    
    func updateMood(id: String, mood: Mood, note: String?, date: Date) async throws -> MoodEntry {
        var body: [String: Any] = [
            "mood": mood.rawValue,
            "date": DataMapper.formatDateOnly(date)
        ]
        if let note = note { body["note"] = note }
        
        let data = try JSONSerialization.data(withJSONObject: body)
        let dto: MoodEntryDTO = try await apiClient.request(
            path: "/moods/\(id)/",
            method: HTTPMethod.patch,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Mood
    
    func deleteMood(id: String) async throws {
        try await apiClient.requestVoid(path: "/moods/\(id)/", method: .delete)
    }
    
    // MARK: - Fetch Mood Stats
    
    func fetchMoodStats() async throws -> MoodStats {
        let dto: MoodStatsDTO = try await apiClient.request(path: "/moods/stats/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Helpers
    
    private func buildQueryParams(page: Int?, search: String?, ordering: String?) -> [String] {
        var params: [String] = []
        if let page = page { params.append("page=\(page)") }
        if let search = search { params.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") }
        if let ordering = ordering { params.append("ordering=\(ordering)") }
        return params
    }
}
