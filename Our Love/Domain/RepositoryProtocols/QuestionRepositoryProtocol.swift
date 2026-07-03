import Foundation

// MARK: - Question Repository Protocol

protocol QuestionRepositoryProtocol {
    func fetchTodayQuestion() async throws -> QuestionOfTheDay?
    func fetchQuestions(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<QuestionOfTheDay>
    func fetchQuestion(id: String) async throws -> QuestionOfTheDay
    func createQuestion(question: String, dateAssigned: Date) async throws -> QuestionOfTheDay
    func submitAnswer(questionID: String, text: String) async throws -> Answer
    func fetchAnswers(questionID: String, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<Answer>
    func generateQuestion() async throws
    func fetchQuestionTemplates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<QuestionTemplate>
}
