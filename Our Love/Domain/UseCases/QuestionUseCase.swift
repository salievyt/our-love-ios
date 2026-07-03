import Foundation

// MARK: - Question Use Case Protocol

protocol QuestionUseCaseType {
    func fetchTodayQuestion() async throws -> QuestionOfTheDay?
    func fetchQuestions() async throws -> PaginatedResponse<QuestionOfTheDay>
    func submitAnswer(questionID: String, text: String) async throws -> Answer
    func generateQuestion() async throws
    func fetchQuestionTemplates() async throws -> PaginatedResponse<QuestionTemplate>
}

// MARK: - Question Use Case

final class QuestionUseCase: QuestionUseCaseType {
    
    private let questionRepo: QuestionRepositoryProtocol
    
    init(questionRepo: QuestionRepositoryProtocol) {
        self.questionRepo = questionRepo
    }
    
    func fetchTodayQuestion() async throws -> QuestionOfTheDay? {
        try await questionRepo.fetchTodayQuestion()
    }
    
    func fetchQuestions() async throws -> PaginatedResponse<QuestionOfTheDay> {
        try await questionRepo.fetchQuestions(page: nil, search: nil, ordering: nil)
    }
    
    func submitAnswer(questionID: String, text: String) async throws -> Answer {
        try await questionRepo.submitAnswer(questionID: questionID, text: text)
    }
    
    func generateQuestion() async throws {
        try await questionRepo.generateQuestion()
    }
    
    func fetchQuestionTemplates() async throws -> PaginatedResponse<QuestionTemplate> {
        try await questionRepo.fetchQuestionTemplates(page: nil, search: nil, ordering: nil)
    }
}
