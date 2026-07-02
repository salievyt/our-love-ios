//  ContentView.swift
//  Our Love

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
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
