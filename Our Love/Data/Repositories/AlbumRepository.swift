import Foundation

// MARK: - Album Repository Implementation

final class AlbumRepository: AlbumRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Photos
    
    func fetchPhotos(page: Int?, yearTag: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Photo> {
        var path = "/albums/"
        var params = buildQueryParams(page: page, search: search, ordering: ordering)
        if let yearTag = yearTag {
            params.append("year_tag=\(yearTag)")
        }
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<PhotoDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<Photo>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Photo by ID
    
    func fetchPhoto(id: String) async throws -> Photo {
        let dto: PhotoDTO = try await apiClient.request(path: "/albums/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Upload Photo
    
    func uploadPhoto(imageData: Data, caption: String?, latitude: Double?, longitude: Double?) async throws -> Photo {
        var fields: [String: String] = [:]
        if let caption = caption { fields["caption"] = caption }
        if let lat = latitude { fields["latitude"] = String(lat) }
        if let lon = longitude { fields["longitude"] = String(lon) }
        
        let data = try await apiClient.uploadMultipart(
            path: "/albums/",
            method: .post,
            fields: fields,
            fileData: imageData,
            fileName: "photo.jpg",
            fieldName: "image",
            mimeType: "image/jpeg"
        )
        
        let dto: PhotoDTO = try JSONDecoder().decode(PhotoDTO.self, from: data)
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Photo
    
    func updatePhoto(id: String, caption: String?, imageData: Data?) async throws -> Photo {
        if let imageData = imageData {
            var fields: [String: String] = [:]
            if let caption = caption { fields["caption"] = caption }
            
            let data = try await apiClient.uploadMultipart(
                path: "/albums/\(id)/",
                method: .put,
                fields: fields,
                fileData: imageData,
                fileName: "photo.jpg",
                fieldName: "image",
                mimeType: "image/jpeg"
            )
            
            let dto: PhotoDTO = try JSONDecoder().decode(PhotoDTO.self, from: data)
            return DataMapper.toDomain(dto)
        } else {
            // Patch without image
            var body: [String: Any] = [:]
            if let caption = caption { body["caption"] = caption }
            let data = try JSONSerialization.data(withJSONObject: body)
            
            let dto: PhotoDTO = try await apiClient.request(
                path: "/albums/\(id)/",
                method: .patch,
                body: data
            )
            return DataMapper.toDomain(dto)
        }
    }
    
    // MARK: - Delete Photo
    
    func deletePhoto(id: String) async throws {
        try await apiClient.requestVoid(path: "/albums/\(id)/", method: .delete)
    }
    
    // MARK: - Fetch Collages
    
    func fetchCollages(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Collage> {
        var path = "/albums/collages/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<CollageDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<Collage>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Create Collage
    
    func createCollage(title: String, photoIDs: [String]) async throws -> Collage {
        var body: [String: Any] = [
            "title": title,
            "photos": photoIDs
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let dto: CollageDTO = try await apiClient.request(
            path: "/albums/collages/",
            method: .post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Collage
    
    func deleteCollage(id: String) async throws {
        try await apiClient.requestVoid(path: "/albums/collages/\(id)/", method: .delete)
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