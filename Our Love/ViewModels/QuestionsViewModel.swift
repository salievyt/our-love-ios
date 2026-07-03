import Foundation
import SwiftUI
import Combine

// MARK: - Questions ViewModel

@MainActor
final class QuestionsViewModel: ObservableObject {
    
    @Published var todayQuestion: QuestionOfTheDay?
    @Published var questionHistory: [QuestionOfTheDay] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var answerText: String = ""
    @Published var isSubmitting = false
    
    private let questionUseCase: QuestionUseCaseType
    
    init(questionUseCase: QuestionUseCaseType) {
        self.questionUseCase = questionUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            async let todayResult = questionUseCase.fetchTodayQuestion()
            async let historyResult = questionUseCase.fetchQuestions()
            
            let (today, historyResponse) = try await (todayResult, historyResult)
            self.todayQuestion = today
            self.questionHistory = historyResponse.results.filter { $0.id != today?.id }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func submitAnswer() async {
        guard let questionId = todayQuestion?.id,
              !answerText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSubmitting = true
        do {
            _ = try await questionUseCase.submitAnswer(questionID: questionId, text: answerText)
            answerText = ""
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
        isSubmitting = false
    }
}
