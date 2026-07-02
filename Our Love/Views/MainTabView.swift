//  MainTabView.swift
//  Our Love

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "heart.fill")
                }
                .tag(0)
            
            AlbumView()
                .tabItem {
                    Label("Альбом", systemImage: "photo.on.rectangle")
                }
                .tag(1)
            
            TasksView()
                .tabItem {
                    Label("Задания", systemImage: "target")
                }
                .tag(2)
            
            DiaryView()
                .tabItem {
                    Label("Дневник", systemImage: "book.fill")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Label("Ещё", systemImage: "ellipsis.circle")
                }
                .tag(4)
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            RelationshipSettings.self,
            ImportantDate.self,
            SharedPhoto.self,
            DailyTask.self,
            QuestionOfTheDay.self,
            MoodEntry.self,
            DiaryEntry.self,
            Place.self,
            TimeCapsule.self,
            Collage.self,
            Item.self,
        ], inMemory: true)
}
