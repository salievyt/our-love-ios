import Foundation

// MARK: - Diary Repository Implementation

final class DiaryRepository: DiaryRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Entries
    
    func fetchEntries(date: Date?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<DiaryEntry> {
        var path = "/diary/"
        var params: [String] = []
        
        if let date = date {
            params.append("date=\(DataMapper.formatDateOnly(date))")
        }
        if let page = page { params.append("page=\(page)") }
        if let search = search { params.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") }
        if let ordering = ordering { params.append("ordering=\(ordering)") }
        
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<DiaryEntryDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<DiaryEntry>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Today Entry
    
    func fetchTodayEntry() async throws -> DiaryEntry? {
        do {
            let dto: DiaryEntryDTO = try await apiClient.request(path: "/diary/today/")
            return DataMapper.toDomain(dto)
        } catch {
            return nil
        }
    }
    
    // MARK: - Fetch Entry by ID
    
    func fetchEntry(id: String) async throws -> DiaryEntry {
        let dto: DiaryEntryDTO = try await apiClient.request(path: "/diary/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Entry
    
    func createEntry(date: Date, note: String?, photo: Data?, moodPartner1: Int?) async throws -> DiaryEntry {
        var fields: [String: String] = [
            "date": DataMapper.formatDateOnly(date)
        ]
        if let note = note { fields["note"] = note }
        if let moodPartner1 = moodPartner1 { fields["mood_partner1"] = String(moodPartner1) }
        
        let data: DiaryEntryDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/diary/",
                method: .post,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            data = try JSONDecoder().decode(DiaryEntryDTO.self, from: uploadData)
        } else {
            var body: [String: Any] = [
                "date": DataMapper.formatDateOnly(date)
            ]
            if let note = note { body["note"] = note }
            if let moodPartner1 = moodPartner1 { body["mood_partner1"] = moodPartner1 }
            
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            data = try await apiClient.request(
                path: "/diary/",
                method: .post,
                body: jsonData
            )
        }
        
        return DataMapper.toDomain(data)
    }
    
    // MARK: - Update Entry
    
    func updateEntry(id: String, note: String?, photo: Data?, moodPartner1: Int?, moodPartner2: Int?, questionAnswerPartner1: String?, questionAnswerPartner2: String?) async throws -> DiaryEntry {
        var fields: [String: String] = [:]
        if let note = note { fields["note"] = note }
        if let moodPartner1 = moodPartner1 { fields["mood_partner1"] = String(moodPartner1) }
        if let moodPartner2 = moodPartner2 { fields["mood_partner2"] = String(moodPartner2) }
        if let questionAnswerPartner1 = questionAnswerPartner1 { fields["question_answer_partner1"] = questionAnswerPartner1 }
        if let questionAnswerPartner2 = questionAnswerPartner2 { fields["question_answer_partner2"] = questionAnswerPartner2 }
        
        let data: DiaryEntryDTO
        if let photo = photo {
            let uploadData = try await apiClient.uploadMultipart(
                path: "/diary/\(id)/",
                method: .patch,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            data = try JSONDecoder().decode(DiaryEntryDTO.self, from: uploadData)
        } else if !fields.isEmpty {
            let jsonData = try JSONSerialization.data(withJSONObject: fields)
            data = try await apiClient.request(
                path: "/diary/\(id)/",
                method: .patch,
                body: jsonData
            )
        } else {
            data = try await apiClient.request(path: "/diary/\(id)/")
        }
        
        return DataMapper.toDomain(data)
    }
    
    // MARK: - Delete Entry
    
    func deleteEntry(id: String) async throws {
        try await apiClient.requestVoid(path: "/diary/\(id)/", method: .delete)
    }
}
