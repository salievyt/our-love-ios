import Foundation

// MARK: - Mood Enum

enum Mood: Int, Codable, CaseIterable {
    case sad = 1
    case down = 2
    case neutral = 3
    case happy = 4
    case loved = 5
    
    var emoji: String {
        switch self {
        case .sad: return "😢"
        case .down: return "😔"
        case .neutral: return "😐"
        case .happy: return "😊"
        case .loved: return "🥰"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .sad: return "cloud.rain.fill"
        case .down: return "cloud.fill"
        case .neutral: return "face.neutral"
        case .happy: return "face.smiling"
        case .loved: return "heart.circle.fill"
        }
    }
    
    var label: String {
        switch self {
        case .sad: return "Ужасно"
        case .down: return "Плохо"
        case .neutral: return "Нормально"
        case .happy: return "Хорошо"
        case .loved: return "Прекрасно"
        }
    }
}
