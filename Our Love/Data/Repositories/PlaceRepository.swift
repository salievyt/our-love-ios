import Foundation

// MARK: - Place Repository Implementation

final class PlaceRepository: PlaceRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Places
    
    func fetchPlaces(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Place> {
        var path = "/places/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<PlaceDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<Place>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Place by ID
    
    func fetchPlace(id: String) async throws -> Place {
        let dto: PlaceDTO = try await apiClient.request(path: "/places/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Place
    
    func createPlace(title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data?) async throws -> Place {
        var fields: [String: String] = [
            "title": title,
            "description": description,
            "emoji": emoji,
            "latitude": String(latitude),
            "longitude": String(longitude)
        ]
        
        let dto: PlaceDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/places/",
                method: .post,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            dto = try JSONDecoder().decode(PlaceDTO.self, from: uploadData)
        } else {
            let data = try JSONSerialization.data(withJSONObject: fields)
            dto = try await apiClient.request(
                path: "/places/",
                method: .post,
                body: data
            )
        }
        
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Place
    
    func updatePlace(id: String, title: String, description: String, emoji: String, latitude: Double, longitude: Double, photo: Data?) async throws -> Place {
        var fields: [String: String] = [
            "title": title,
            "description": description,
            "emoji": emoji,
            "latitude": String(latitude),
            "longitude": String(longitude)
        ]
        
        let dto: PlaceDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/places/\(id)/",
                method: .patch,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            dto = try JSONDecoder().decode(PlaceDTO.self, from: uploadData)
        } else {
            let data = try JSONSerialization.data(withJSONObject: fields)
            dto = try await apiClient.request(
                path: "/places/\(id)/",
                method: .patch,
                body: data
            )
        }
        
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Place
    
    func deletePlace(id: String) async throws {
        try await apiClient.requestVoid(path: "/places/\(id)/", method: .delete)
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