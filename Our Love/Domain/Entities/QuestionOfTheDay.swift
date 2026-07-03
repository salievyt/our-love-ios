import Foundation

// MARK: - Question Entity

struct QuestionOfTheDay: Identifiable, Equatable, Codable {
    let id: String
    let question: String
    let dateAssigned: Date
    let answers: [Answer]
    let partner1Answered: Bool
    let partner2Answered: Bool
    let bothAnswered: Bool
}
