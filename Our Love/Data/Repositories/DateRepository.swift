import Foundation

// MARK: - Date Repository Implementation

final class DateRepository: DateRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Dates
    
    func fetchDates(isAnnually: Bool?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<ImportantDate> {
        var path = "/dates/"
        var params: [String] = []
        
        if let isAnnually = isAnnually {
            params.append("is_annually=\(isAnnually)")
        }
        if let page = page { params.append("page=\(page)") }
        if let search = search { params.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") }
        if let ordering = ordering { params.append("ordering=\(ordering)") }
        
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<ImportantDateDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<ImportantDate>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Upcoming Dates
    
    func fetchUpcomingDates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<ImportantDate> {
        var path = "/dates/upcoming/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<ImportantDateDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<ImportantDate>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Date by ID
    
    func fetchDate(id: String) async throws -> ImportantDate {
        let dto: ImportantDateDTO = try await apiClient.request(path: "/dates/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Date
    
    func createDate(title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate {
        var body: [String: Any] = [
            "title": title,
            "date": DataMapper.formatDateOnly(date),
            "emoji": emoji,
            "is_annually": isAnnually
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let dto: ImportantDateDTO = try await apiClient.request(
            path: "/dates/",
            method: HTTPMethod.post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Date
    
    func updateDate(id: String, title: String, date: Date, emoji: String, isAnnually: Bool) async throws -> ImportantDate {
        var body: [String: Any] = [
            "title": title,
            "date": DataMapper.formatDateOnly(date),
            "emoji": emoji,
            "is_annually": isAnnually
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let dto: ImportantDateDTO = try await apiClient.request(
            path: "/dates/\(id)/",
            method: .patch,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Date
    
    func deleteDate(id: String) async throws {
        try await apiClient.requestVoid(path: "/dates/\(id)/", method: .delete)
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
