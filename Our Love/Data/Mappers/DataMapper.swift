import Foundation

// MARK: - DataMapper

enum DataMapper {
    
    // MARK: - User
    
    static func toDomain(_ dto: UserProfileDTO) -> User {
        User(
            id: dto.id,
            username: dto.username,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            avatarURL: dto.avatar,
            phone: dto.phone
        )
    }
    
    // MARK: - Relationship
    
    static func toDomain(_ dto: RelationshipDTO) -> Relationship {
        Relationship(
            id: dto.id,
            partner1: toDomain(dto.partner1),
            partner2: dto.partner2.map { toDomain($0) },
            partner1Name: dto.partner1Name,
            partner2Name: dto.partner2Name,
            partner1Emoji: dto.partner1Emoji,
            partner2Emoji: dto.partner2Emoji,
            startDate: parseDate(dto.relationshipStartDate),
            daysTogether: dto.daysTogether
        )
    }
    
    // MARK: - Photo
    
    static func toDomain(_ dto: PhotoDTO) -> Photo {
        Photo(
            id: dto.id,
            imageURL: dto.imageURL,
            image: dto.image,
            caption: dto.caption,
            createdAt: parseDate(dto.createdAt),
            yearTag: dto.yearTag,
            latitude: dto.latitude,
            longitude: dto.longitude
        )
    }
    
    // MARK: - Collage
    
    static func toDomain(_ dto: CollageDTO) -> Collage {
        Collage(
            id: dto.id,
            title: dto.title,
            imageURL: dto.imageURL,
            photoIDs: dto.photos,
            photoCount: dto.photoCount,
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Daily Task
    
    static func toDomain(_ dto: DailyTaskDTO) -> DailyTask {
        DailyTask(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            emoji: dto.emoji,
            isCompleted: dto.isCompleted,
            completedAt: dto.completedAt.map { parseDate($0) },
            photoURL: dto.photoURL.isEmpty ? nil : dto.photoURL,
            dateAssigned: parseDate(dto.dateAssigned),
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Question
    
    static func toDomain(_ dto: QuestionOfTheDayDTO) -> QuestionOfTheDay {
        QuestionOfTheDay(
            id: dto.id,
            question: dto.question,
            dateAssigned: parseDate(dto.dateAssigned),
            answers: dto.answers.map { toDomain($0) },
            partner1Answered: dto.partner1AnsweredBool,
            partner2Answered: dto.partner2AnsweredBool,
            bothAnswered: dto.bothAnsweredBool
        )
    }
    
    // MARK: - Answer
    
    static func toDomain(_ dto: AnswerDTO) -> Answer {
        Answer(
            id: dto.id,
            questionID: dto.question,
            user: dto.user,
            text: dto.text,
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Diary Entry
    
    static func toDomain(_ dto: DiaryEntryDTO) -> DiaryEntry {
        DiaryEntry(
            id: dto.id,
            date: parseDate(dto.date),
            note: dto.note,
            photoURL: dto.photoURL.isEmpty ? nil : dto.photoURL,
            moodPartner1: dto.moodPartner1,
            moodPartner2: dto.moodPartner2,
            questionAnswerPartner1: dto.questionAnswerPartner1,
            questionAnswerPartner2: dto.questionAnswerPartner2,
            createdAt: parseDate(dto.createdAt),
            updatedAt: parseDate(dto.updatedAt)
        )
    }
    
    // MARK: - Mood Entry
    
    static func toDomain(_ dto: MoodEntryDTO) -> MoodEntry {
        MoodEntry(
            id: dto.id,
            userID: dto.user,
            mood: Mood(rawValue: dto.mood) ?? .neutral,
            note: dto.note,
            date: parseDate(dto.date),
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Mood Stats
    
    static func toDomain(_ dto: MoodStatsDTO) -> MoodStats {
        var distribution: [Mood: Int] = [:]
        for (key, value) in dto.distribution {
            if let mood = Mood(rawValue: key) {
                distribution[mood] = value
            }
        }
        return MoodStats(
            totalEntries: dto.totalEntries,
            averageMood: dto.averageMood,
            streak: dto.streak,
            distribution: distribution
        )
    }
    
    // MARK: - Place
    
    static func toDomain(_ dto: PlaceDTO) -> Place {
        Place(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            emoji: dto.emoji,
            latitude: dto.latitude,
            longitude: dto.longitude,
            photoURL: dto.photoURL.isEmpty ? nil : dto.photoURL,
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Time Capsule
    
    static func toDomain(_ dto: TimeCapsuleDTO) -> TimeCapsule {
        TimeCapsule(
            id: dto.id,
            title: dto.title,
            message: dto.message,
            photoURL: dto.photoURL.isEmpty ? nil : dto.photoURL,
            voiceNoteURL: dto.voiceNoteURL.isEmpty ? nil : dto.voiceNoteURL,
            openDate: parseDate(dto.openDate),
            isOpened: dto.isOpened,
            isReadyToOpen: dto.isReadyToOpen,
            daysUntilOpen: Int(dto.daysUntilOpen) ?? 0,
            openedAt: dto.openedAt.map { parseDate($0) },
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Important Date
    
    static func toDomain(_ dto: ImportantDateDTO) -> ImportantDate {
        ImportantDate(
            id: dto.id,
            relationshipID: dto.relationship,
            title: dto.title,
            date: parseDate(dto.date),
            emoji: dto.emoji,
            isAnnually: dto.isAnnually,
            daysUntil: dto.daysUntil,
            createdAt: parseDate(dto.createdAt)
        )
    }
    
    // MARK: - Task Template
    
    static func toDomain(_ dto: TaskTemplateDTO) -> TaskTemplate {
        TaskTemplate(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            emoji: dto.emoji
        )
    }
    
    // MARK: - Question Template
    
    static func toDomain(_ dto: QuestionTemplateDTO) -> QuestionTemplate {
        QuestionTemplate(
            id: dto.id,
            text: dto.text
        )
    }
    
    // MARK: - Helpers
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static func parseDate(_ dateString: String) -> Date {
        // Try ISO8601 first
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        // Try date only
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        // Fallback
        return Date()
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
    
    static func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
