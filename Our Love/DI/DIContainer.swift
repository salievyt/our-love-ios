import Foundation

// MARK: - Dependency Container

/// Central DI container for the entire app.
/// All shared dependencies are instantiated here and injected into ViewModels.
final class DIContainer {
    
    static let shared = DIContainer()
    
    // MARK: - API Layer
    
    private(set) lazy var apiClient: APIClient = {
        APIClient.shared
    }()
    
    // MARK: - Repository Layer
    
    private(set) lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var albumRepository: AlbumRepositoryProtocol = {
        AlbumRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var taskRepository: TaskRepositoryProtocol = {
        TaskRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var questionRepository: QuestionRepositoryProtocol = {
        QuestionRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var diaryRepository: DiaryRepositoryProtocol = {
        DiaryRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var moodRepository: MoodRepositoryProtocol = {
        MoodRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var placeRepository: PlaceRepositoryProtocol = {
        PlaceRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var capsuleRepository: CapsuleRepositoryProtocol = {
        CapsuleRepository(apiClient: apiClient)
    }()
    
    private(set) lazy var dateRepository: DateRepositoryProtocol = {
        DateRepository(apiClient: apiClient)
    }()
    
    // MARK: - Use Cases
    
    private(set) lazy var homeUseCase: HomeUseCaseType = {
        HomeUseCase(
            authRepo: authRepository,
            dateRepo: dateRepository,
            taskRepo: taskRepository,
            questionRepo: questionRepository,
            moodRepo: moodRepository
        )
    }()
    
    private(set) lazy var albumUseCase: AlbumUseCaseType = {
        AlbumUseCase(albumRepo: albumRepository)
    }()
    
    private(set) lazy var taskUseCase: TaskUseCaseType = {
        TaskUseCase(taskRepo: taskRepository)
    }()
    
    private(set) lazy var questionUseCase: QuestionUseCaseType = {
        QuestionUseCase(questionRepo: questionRepository)
    }()
    
    private(set) lazy var diaryUseCase: DiaryUseCaseType = {
        DiaryUseCase(diaryRepo: diaryRepository)
    }()
    
    private(set) lazy var moodUseCase: MoodUseCaseType = {
        MoodUseCase(moodRepo: moodRepository)
    }()
    
    private(set) lazy var placeUseCase: PlaceUseCaseType = {
        PlaceUseCase(placeRepo: placeRepository)
    }()
    
    private(set) lazy var capsuleUseCase: CapsuleUseCaseType = {
        CapsuleUseCase(capsuleRepo: capsuleRepository)
    }()
    
    private(set) lazy var dateUseCase: DateUseCaseType = {
        DateUseCase(dateRepo: dateRepository)
    }()
    
    // MARK: - Auth Service (for UI state)
    
    private(set) lazy var authService: any AuthServiceType = {
        AuthServiceImpl(authRepo: authRepository)
    }()
    
    // MARK: - Private Init
    
    private init() {}
}
