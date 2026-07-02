// MARK: - Models.swift
// SwiftData models for Our Love app

import Foundation
import SwiftData
import CoreLocation

// MARK: - Relationship Settings
@Model
final class RelationshipSettings {
    var partner1Name: String
    var partner2Name: String
    var relationshipStartDate: Date
    var partner1Emoji: String
    var partner2Emoji: String
    
    init(partner1Name: String = "Ты", partner2Name: String = "Второй половинка",
         relationshipStartDate: Date = Date(), partner1Emoji: String = "💙", partner2Emoji: String = "💖") {
        self.partner1Name = partner1Name
        self.partner2Name = partner2Name
        self.relationshipStartDate = relationshipStartDate
        self.partner1Emoji = partner1Emoji
        self.partner2Emoji = partner2Emoji
    }
}

// MARK: - Important Date
@Model
final class ImportantDate {
    var title: String
    var date: Date
    var emoji: String
    var isAnnually: Bool
    var createdAt: Date
    
    init(title: String, date: Date, emoji: String = "❤️", isAnnually: Bool = true) {
        self.title = title
        self.date = date
        self.emoji = emoji
        self.isAnnually = isAnnually
        self.createdAt = Date()
    }
}

// MARK: - Shared Photo
@Model
final class SharedPhoto {
    var imageData: Data?
    var caption: String
    var createdAt: Date
    var yearTag: Int
    var latitude: Double?
    var longitude: Double?
    
    init(imageData: Data? = nil, caption: String = "", createdAt: Date = Date()) {
        self.imageData = imageData
        self.caption = caption
        self.createdAt = createdAt
        self.yearTag = Calendar.current.component(.year, from: createdAt)
    }
}

// MARK: - Daily Task
@Model
final class DailyTask {
    var title: String
    var taskDescription: String
    var emoji: String
    var isCompleted: Bool
    var completedAt: Date?
    var photoData: Data?
    var dateAssigned: Date
    
    init(title: String, taskDescription: String, emoji: String = "🎯", dateAssigned: Date = Date()) {
        self.title = title
        self.taskDescription = taskDescription
        self.emoji = emoji
        self.isCompleted = false
        self.dateAssigned = dateAssigned
    }
}

// MARK: - Question of the Day
@Model
final class QuestionOfTheDay {
    var question: String
    var answerPartner1: String?
    var answerPartner2: String?
    var partner1AnsweredAt: Date?
    var partner2AnsweredAt: Date?
    var dateAssigned: Date
    
    var isFullyAnswered: Bool {
        answerPartner1 != nil && answerPartner2 != nil
    }
    
    init(question: String, dateAssigned: Date = Date()) {
        self.question = question
        self.dateAssigned = dateAssigned
    }
}

// MARK: - Mood Entry
@Model
final class MoodEntry {
    var moodPartner1: Int  // 1-5
    var moodPartner2: Int? // 1-5
    var notePartner1: String?
    var notePartner2: String?
    var date: Date
    var partner1LoggedAt: Date?
    var partner2LoggedAt: Date?
    
    var averageMood: Double {
        if let m2 = moodPartner2 {
            return (Double(moodPartner1) + Double(m2)) / 2.0
        }
        return Double(moodPartner1)
    }
    
    init(moodPartner1: Int, date: Date = Date(), notePartner1: String? = nil) {
        self.moodPartner1 = moodPartner1
        self.date = date
        self.notePartner1 = notePartner1
    }
}

// MARK: - Diary Entry
@Model
final class DiaryEntry {
    var date: Date
    var questionRef: String?
    var partner1Answer: String?
    var partner2Answer: String?
    var partner1Mood: Int?
    var partner2Mood: Int?
    var photoData: Data?
    var note: String?
    
    init(date: Date = Date()) {
        self.date = date
    }
}

// MARK: - Place (Map)
@Model
final class Place {
    var title: String
    var placeDescription: String
    var emoji: String
    var latitude: Double
    var longitude: Double
    var photoData: Data?
    var createdAt: Date
    
    init(title: String, placeDescription: String = "", emoji: String = "📍",
         latitude: Double, longitude: Double) {
        self.title = title
        self.placeDescription = placeDescription
        self.emoji = emoji
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = Date()
    }
}

// MARK: - Time Capsule
@Model
final class TimeCapsule {
    var title: String
    var message: String
    var createdAt: Date
    var openDate: Date
    var isOpened: Bool
    var photoData: Data?
    var voiceNoteData: Data?
    
    var isReadyToOpen: Bool {
        Date() >= openDate && !isOpened
    }
    
    init(title: String, message: String, openDate: Date) {
        self.title = title
        self.message = message
        self.openDate = openDate
        self.createdAt = Date()
        self.isOpened = false
    }
}

// MARK: - Collage
@Model
final class Collage {
    var title: String
    var createdAt: Date
    var photoData: Data?
    
    init(title: String, createdAt: Date = Date()) {
        self.title = title
        self.createdAt = createdAt
    }
}
