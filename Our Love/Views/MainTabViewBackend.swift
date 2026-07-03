import SwiftUI

// MARK: - Main Tab View Backend

struct MainTabViewBackend: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authService: AuthServiceImpl
    
    // MARK: - ViewModels (DI)
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var albumViewModel: AlbumViewModel
    @StateObject private var tasksViewModel: TasksViewModel
    @StateObject private var questionsViewModel: QuestionsViewModel
    @StateObject private var diaryViewModel: DiaryViewModel
    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var moreViewModel: MoreViewModel
    @StateObject private var timeCapsuleViewModel: TimeCapsuleViewModel
    @StateObject private var posterViewModel: PosterGeneratorViewModel
    
    init() {
        let authService = AuthServiceImpl(authRepo: DIContainer.shared.authRepository)
        
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(
            homeUseCase: DIContainer.shared.homeUseCase,
            dateUseCase: DIContainer.shared.dateUseCase
        ))
        _albumViewModel = StateObject(wrappedValue: AlbumViewModel(
            albumUseCase: DIContainer.shared.albumUseCase
        ))
        _tasksViewModel = StateObject(wrappedValue: TasksViewModel(
            taskUseCase: DIContainer.shared.taskUseCase
        ))
        _questionsViewModel = StateObject(wrappedValue: QuestionsViewModel(
            questionUseCase: DIContainer.shared.questionUseCase
        ))
        _diaryViewModel = StateObject(wrappedValue: DiaryViewModel(
            diaryUseCase: DIContainer.shared.diaryUseCase
        ))
        _mapViewModel = StateObject(wrappedValue: MapViewModel(
            placeUseCase: DIContainer.shared.placeUseCase
        ))
        _moreViewModel = StateObject(wrappedValue: MoreViewModel(
            moodUseCase: DIContainer.shared.moodUseCase,
            authService: authService,
            albumUseCase: DIContainer.shared.albumUseCase,
            diaryUseCase: DIContainer.shared.diaryUseCase,
            taskUseCase: DIContainer.shared.taskUseCase
        ))
        _timeCapsuleViewModel = StateObject(wrappedValue: TimeCapsuleViewModel(
            capsuleUseCase: DIContainer.shared.capsuleUseCase
        ))
        _posterViewModel = StateObject(wrappedValue: PosterGeneratorViewModel(
            albumUseCase: DIContainer.shared.albumUseCase,
            authService: authService
        ))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeViewBackend()
                .environmentObject(homeViewModel)
                .environmentObject(authService)
                .tabItem {
                    Label("Главная", systemImage: "heart.fill")
                }
                .tag(0)
            
            AlbumViewBackend()
                .environmentObject(albumViewModel)
                .tabItem {
                    Label("Альбом", systemImage: "photo.on.rectangle")
                }
                .tag(1)
            
            TasksViewBackend()
                .environmentObject(tasksViewModel)
                .tabItem {
                    Label("Задания", systemImage: "target")
                }
                .tag(2)
            
            MapViewBackend()
                .environmentObject(mapViewModel)
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
                .tag(3)
            
            QuestionsViewBackend()
                .environmentObject(questionsViewModel)
                .tabItem {
                    Label("Вопросы", systemImage: "questionmark.bubble")
                }
                .tag(4)
            
            DiaryViewBackend()
                .environmentObject(diaryViewModel)
                .tabItem {
                    Label("Дневник", systemImage: "book")
                }
                .tag(5)
            
            MoreViewBackend()
                .environmentObject(moreViewModel)
                .tabItem {
                    Label("Ещё", systemImage: "ellipsis.circle")
                }
                .tag(6)
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabViewBackend()
        .environmentObject(AuthServiceImpl(authRepo: DIContainer.shared.authRepository))
}