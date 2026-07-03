import Foundation

// MARK: - Question DTOs

struct QuestionOfTheDayDTO: Codable, Identifiable {
    let id: String
    let question: String
    let dateAssigned: String
    let answers: [AnswerDTO]
    let partner1Answered: String
    let partner2Answered: String
    let bothAnswered: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, question
        case dateAssigned = "date_assigned"
        case answers
        case partner1Answered = "partner1_answered"
        case partner2Answered = "partner2_answered"
        case bothAnswered = "both_answered"
        case createdAt = "created_at"
    }
    
    var partner1AnsweredBool: Bool {
        partner1Answered.lowercased() == "true" || partner1Answered == "1"
    }
    
    var partner2AnsweredBool: Bool {
        partner2Answered.lowercased() == "true" || partner2Answered == "1"
    }
    
    var bothAnsweredBool: Bool {
        bothAnswered.lowercased() == "true" || bothAnswered == "1"
    }
}

struct AnswerDTO: Codable, Identifiable {
    let id: String
    let question: String
    let user: String
    let text: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, question, user, text
        case createdAt = "created_at"
    }
}

struct AnswerCreateDTO: Codable {
    let text: String
}

struct QuestionTemplateDTO: Codable, Identifiable {
    let id: Int
    let text: String
}
