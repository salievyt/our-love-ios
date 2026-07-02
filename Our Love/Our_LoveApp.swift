//  Our_LoveApp.swift
//  Our Love

import SwiftUI
import SwiftData

@main
struct Our_LoveApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
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
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
