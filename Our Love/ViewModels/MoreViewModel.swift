import Foundation
import SwiftUI
import Combine

// MARK: - More ViewModel

@MainActor
final class MoreViewModel: ObservableObject {
    
    @Published var moods: [MoodEntry] = []
    @Published var moodStats: MoodStats?
    @Published var taskCount: Int = 0
    @Published var photoCount: Int = 0
    @Published var diaryCount: Int = 0
    
    @Published var partner1Name: String = ""
    @Published var partner2Name: String = ""
    @Published var startDate: Date = Date()
    
    @Published var isLoading = false
    @Published var error: String?
    
    private let moodUseCase: MoodUseCaseType
    private let authService: any AuthServiceType
    private let albumUseCase: AlbumUseCaseType
    private let diaryUseCase: DiaryUseCaseType
    private let taskUseCase: TaskUseCaseType
    
    var daysTogether: Int {
        if let rel = authService.relationship {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: rel.startDate, to: Date())
            return max(components.day ?? 0, 0)
        }
        return 0
    }
    
    init(
        moodUseCase: MoodUseCaseType,
        authService: any AuthServiceType,
        albumUseCase: AlbumUseCaseType,
        diaryUseCase: DiaryUseCaseType,
        taskUseCase: TaskUseCaseType
    ) {
        self.moodUseCase = moodUseCase
        self.authService = authService
        self.albumUseCase = albumUseCase
        self.diaryUseCase = diaryUseCase
        self.taskUseCase = taskUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        if let rel = authService.relationship {
            partner1Name = rel.partner1Name
            partner2Name = rel.partner2Name
            startDate = rel.startDate
        }
        
        async let moodsTask: () = loadMoods()
        async let statsTask: () = loadStats()
        async let countsTask: () = loadCounts()
        
        let _ = await (moodsTask, statsTask, countsTask)
        
        isLoading = false
    }
    
    private func loadMoods() async {
        do {
            let response = try await moodUseCase.fetchMoods()
            moods = response.results
        } catch { }
    }
    
    private func loadStats() async {
        do {
            moodStats = try await moodUseCase.fetchMoodStats()
        } catch { }
    }
    
    private func loadCounts() async {
        do {
            async let tasks = taskUseCase.fetchTasks(isCompleted: nil, dateAssigned: nil)
            async let photos = albumUseCase.fetchPhotos(page: nil, yearTag: nil, search: nil)
            async let diary = diaryUseCase.fetchEntries(date: nil)
            
            let (tasksResponse, photosResponse, diaryResponse) = try await (tasks, photos, diary)
            self.taskCount = tasksResponse.results.filter { $0.isCompleted }.count
            self.photoCount = photosResponse.results.count
            self.diaryCount = diaryResponse.results.count
        } catch { }
    }
    
    func logout() async {
        await authService.logout()
    }
    
    func moodEmoji(for value: Mood) -> String {
        value.emoji
    }
    
    func moodText(for value: Mood) -> String {
        value.label
    }
}
