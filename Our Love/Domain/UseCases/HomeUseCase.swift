import Foundation

// MARK: - Home Use Case Protocol

@MainActor
protocol HomeUseCaseType {
    func fetchHomeData() async throws -> HomeData
    func saveMood(mood: Mood, note: String?) async throws
}

// MARK: - Home Use Case

@MainActor
final class HomeUseCase: HomeUseCaseType {
    
    private let authRepo: AuthRepositoryProtocol
    private let dateRepo: DateRepositoryProtocol
    private let taskRepo: TaskRepositoryProtocol
    private let questionRepo: QuestionRepositoryProtocol
    private let moodRepo: MoodRepositoryProtocol
    
    nonisolated init(
        authRepo: AuthRepositoryProtocol,
        dateRepo: DateRepositoryProtocol,
        taskRepo: TaskRepositoryProtocol,
        questionRepo: QuestionRepositoryProtocol,
        moodRepo: MoodRepositoryProtocol
    ) {
        self.authRepo = authRepo
        self.dateRepo = dateRepo
        self.taskRepo = taskRepo
        self.questionRepo = questionRepo
        self.moodRepo = moodRepo
    }
    
    func fetchHomeData() async throws -> HomeData {
        async let dates = dateRepo.fetchUpcomingDates(page: nil, search: nil, ordering: nil)
        async let task = taskRepo.fetchTodayTask()
        async let question = questionRepo.fetchTodayQuestion()
        async let mood = moodRepo.fetchTodayMood()
        
        let (datesResponse, todayTask, todayQuestion, todayMood) = try await (dates, task, question, mood)
        
        let rel = authRepo.relationship
        let daysTogether = rel?.daysTogether ?? 0
        let startDate = rel?.startDate ?? Date()
        
        return HomeData(
            daysTogether: daysTogether,
            startDate: startDate,
            partner1Name: rel?.partner1Name ?? "Ты",
            partner2Name: rel?.partner2Name ?? "Второй половинка",
            upcomingDates: datesResponse.results,
            todayTask: todayTask,
            todayQuestion: todayQuestion,
            todayMood: todayMood
        )
    }
    
    func saveMood(mood: Mood, note: String?) async throws {
        _ = try await moodRepo.createMood(mood: mood, note: note, date: Date())
    }
}

// MARK: - Home Data

struct HomeData: Equatable {
    let daysTogether: Int
    let startDate: Date
    let partner1Name: String
    let partner2Name: String
    let upcomingDates: [ImportantDate]
    let todayTask: DailyTask?
    let todayQuestion: QuestionOfTheDay?
    let todayMood: MoodEntry?
}