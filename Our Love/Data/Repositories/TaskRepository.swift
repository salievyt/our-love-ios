import Foundation

// MARK: - Task Repository Implementation

final class TaskRepository: TaskRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Today Task
    
    func fetchTodayTask() async throws -> DailyTask? {
        do {
            let dto: DailyTaskDTO = try await apiClient.request(path: "/tasks/today/")
            return DataMapper.toDomain(dto)
        } catch {
            return nil
        }
    }
    
    // MARK: - Fetch Tasks
    
    func fetchTasks(isCompleted: Bool?, dateAssigned: Date?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<DailyTask> {
        var path = "/tasks/"
        var params: [String] = []
        
        if let isCompleted = isCompleted {
            params.append("is_completed=\(isCompleted)")
        }
        if let dateAssigned = dateAssigned {
            params.append("date_assigned=\(DataMapper.formatDateOnly(dateAssigned))")
        }
        if let page = page { params.append("page=\(page)") }
        if let search = search { params.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") }
        if let ordering = ordering { params.append("ordering=\(ordering)") }
        
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<DailyTaskDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<DailyTask>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Task by ID
    
    func fetchTask(id: String) async throws -> DailyTask {
        let dto: DailyTaskDTO = try await apiClient.request(path: "/tasks/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Task
    
    func createTask(title: String, description: String, emoji: String, dateAssigned: Date) async throws -> DailyTask {
        var body: [String: Any] = [
            "title": title,
            "description": description,
            "emoji": emoji,
            "date_assigned": DataMapper.formatDateOnly(dateAssigned)
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let dto: DailyTaskDTO = try await apiClient.request(
            path: "/tasks/",
            method: .post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Update Task
    
    func updateTask(id: String, title: String, description: String, emoji: String, isCompleted: Bool?, completedAt: Date?, photo: Data?) async throws -> DailyTask {
        if let photo = photo {
            var fields: [String: String] = [
                "title": title,
                "description": description,
                "emoji": emoji
            ]
            if let isCompleted = isCompleted { fields["is_completed"] = String(isCompleted) }
            if let completedAt = completedAt { fields["completed_at"] = DataMapper.formatDate(completedAt) }
            
            let data = try await apiClient.uploadMultipart(
                path: "/tasks/\(id)/",
                method: .patch,
                fields: fields,
                fileData: photo,
                fileName: "photo.jpg",
                fieldName: "photo",
                mimeType: "image/jpeg"
            )
            
            let dto: DailyTaskDTO = try JSONDecoder().decode(DailyTaskDTO.self, from: data)
            return DataMapper.toDomain(dto)
        } else {
            var body: [String: Any] = [
                "title": title,
                "description": description,
                "emoji": emoji
            ]
            if let isCompleted = isCompleted { body["is_completed"] = isCompleted }
            if let completedAt = completedAt { body["completed_at"] = DataMapper.formatDate(completedAt) }
            
            let data = try JSONSerialization.data(withJSONObject: body)
            let dto: DailyTaskDTO = try await apiClient.request(
                path: "/tasks/\(id)/",
                method: .patch,
                body: data
            )
            return DataMapper.toDomain(dto)
        }
    }
    
    // MARK: - Complete Task
    
    func completeTask(id: String) async throws -> DailyTask {
        let dto: DailyTaskDTO = try await apiClient.request(
            path: "/tasks/\(id)/complete/",
            method: .put
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Delete Task
    
    func deleteTask(id: String) async throws {
        try await apiClient.requestVoid(path: "/tasks/\(id)/", method: .delete)
    }
    
    // MARK: - Generate Task
    
    func generateTask() async throws -> DailyTask {
        let dto: DailyTaskDTO = try await apiClient.request(
            path: "/tasks/generate/",
            method: .get
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Fetch Task Templates
    
    func fetchTaskTemplates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TaskTemplate> {
        var path = "/tasks/templates/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<TaskTemplateDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<TaskTemplate>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
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