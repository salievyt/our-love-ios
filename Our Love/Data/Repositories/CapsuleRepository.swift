import Foundation

// MARK: - Capsule Repository Implementation

final class CapsuleRepository: CapsuleRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Active Capsules
    
    func fetchActiveCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule> {
        var path = "/capsules/active/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<TimeCapsuleDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<TimeCapsule>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Opened Capsules
    
    func fetchOpenedCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule> {
        var path = "/capsules/opened/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<TimeCapsuleDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<TimeCapsule>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch All Capsules
    
    func fetchCapsules(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TimeCapsule> {
        var path = "/capsules/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<TimeCapsuleDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<TimeCapsule>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Capsule by ID
    
    func fetchCapsule(id: String) async throws -> TimeCapsule {
        let dto: TimeCapsuleDTO = try await apiClient.request(path: "/capsules/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Capsule
    
    func createCapsule(title: String, message: String, openDate: Date, photo: Data?, voiceNote: Data?) async throws -> TimeCapsule {
        var fields: [String: String] = [
            "title": title,
            "message": message,
            "open_date": DataMapper.formatDateOnly(openDate)
        ]
        
        let dto: TimeCapsuleDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/capsules/",
                method: HTTPMethod.post,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            dto = try JSONDecoder().decode(TimeCapsuleDTO.self, from: uploadData)
        } else {
            let data = try JSONSerialization.data(withJSONObject: fields)
            dto = try await apiClient.request(
                path: "/capsules/",
                method: HTTPMethod.post,
                body: data
            )
        }
        
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Capsule
    
    func updateCapsule(id: String, title: String, message: String, openDate: Date, photo: Data?, voiceNote: Data?) async throws -> TimeCapsule {
        var fields: [String: String] = [
            "title": title,
            "message": message,
            "open_date": DataMapper.formatDateOnly(openDate)
        ]
        
        let dto: TimeCapsuleDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/capsules/\(id)/",
                method: HTTPMethod.patch,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            dto = try JSONDecoder().decode(TimeCapsuleDTO.self, from: uploadData)
        } else {
            let data = try JSONSerialization.data(withJSONObject: fields)
            dto = try await apiClient.request(
                path: "/capsules/\(id)/",
                method: HTTPMethod.patch,
                body: data
            )
        }
        
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Open Capsule
    
    func openCapsule(id: String) async throws -> TimeCapsule {
        let request = TimeCapsuleOpenDTO(confirm: true)
        let data = try JSONEncoder().encode(request)
        
        let dto: TimeCapsuleDTO = try await apiClient.request(
            path: "/capsules/\(id)/open/",
            method: HTTPMethod.post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Capsule
    
    func deleteCapsule(id: String) async throws {
        try await apiClient.requestVoid(path: "/capsules/\(id)/", method: HTTPMethod.delete)
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
