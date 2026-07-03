import Foundation

// MARK: - Question Repository Implementation

final class QuestionRepository: QuestionRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Today Question
    
    func fetchTodayQuestion() async throws -> QuestionOfTheDay? {
        do {
            let dto: QuestionOfTheDayDTO = try await apiClient.request(path: "/questions/today/")
            return DataMapper.toDomain(dto)
        } catch {
            return nil
        }
    }
    
    // MARK: - Fetch Questions
    
    func fetchQuestions(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<QuestionOfTheDay> {
        var path = "/questions/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<QuestionOfTheDayDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<QuestionOfTheDay>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Fetch Question by ID
    
    func fetchQuestion(id: String) async throws -> QuestionOfTheDay {
        let dto: QuestionOfTheDayDTO = try await apiClient.request(path: "/questions/\(id)/")
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Create Question
    
    func createQuestion(question: String, dateAssigned: Date) async throws -> QuestionOfTheDay {
        var body: [String: Any] = [
            "question": question,
            "date_assigned": DataMapper.formatDateOnly(dateAssigned)
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let dto: QuestionOfTheDayDTO = try await apiClient.request(
            path: "/questions/",
            method: .post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Submit Answer
    
    func submitAnswer(questionID: String, text: String) async throws -> Answer {
        let request = AnswerCreateDTO(text: text)
        let data = try JSONEncoder().encode(request)
        
        let dto: AnswerDTO = try await apiClient.request(
            path: "/questions/\(questionID)/answers/create/",
            method: .post,
            body: data
        )
        return DataMapper.toDomain(dto)
    }
    
    // MARK: - Fetch Answers
    
    func fetchAnswers(questionID: String, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Answer> {
        var path = "/questions/\(questionID)/answers/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<AnswerDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<Answer>(
            count: dto.count,
            next: dto.next,
            previous: dto.previous,
            results: dto.results.map(DataMapper.toDomain)
        )
    }
    
    // MARK: - Generate Question
    
    func generateQuestion() async throws {
        try await apiClient.requestVoid(
            path: "/questions/generate/",
            method: .get
        )
    }
    
    // MARK: - Fetch Question Templates
    
    func fetchQuestionTemplates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<QuestionTemplate> {
        var path = "/questions/templates/"
        let params = buildQueryParams(page: page, search: search, ordering: ordering)
        if !params.isEmpty {
            path += "?" + params.joined(separator: "&")
        }
        
        let dto: PaginatedResponse<QuestionTemplateDTO> = try await apiClient.request(path: path)
        return PaginatedResponse<QuestionTemplate>(
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