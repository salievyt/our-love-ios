//  MoreView.swift
//  Our Love

import SwiftUI
import SwiftData

struct MoreView: View {
    @Query private var settings: [RelationshipSettings]
    @Environment(\.modelContext) private var modelContext
    
    var settingsData: RelationshipSettings {
        if settings.isEmpty {
            let defaultSettings = RelationshipSettings()
            modelContext.insert(defaultSettings)
            return defaultSettings
        }
        return settings[0]
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Relationship Info
                Section {
                    VStack(spacing: 12) {
                        Text("💕")
                            .font(.system(size: 50))
                        
                        Text("\(daysTogether)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("дней вместе")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                // MARK: - Features
                Section("Разделы") {
                    NavigationLink(destination: MoodHistoryView()) {
                        Label("😊 Настроение", systemImage: "face.smiling")
                    }
                    
                    NavigationLink(destination: MapView()) {
                        Label("🗺 Карта отношений", systemImage: "map.fill")
                    }
                    
                    NavigationLink(destination: TimeCapsuleView()) {
                        Label("⏳ Капсула времени", systemImage: "clock.arrow.2.circlepath")
                    }
                    
                    NavigationLink(destination: PosterGeneratorView()) {
                        Label("🎨 Генератор постеров", systemImage: "sparkles")
                    }
                    
                    NavigationLink(destination: DatesListView()) {
                        Label("❤️ Важные даты", systemImage: "calendar")
                    }
                    
                    NavigationLink(destination: StatisticsView()) {
                        Label("📊 Статистика", systemImage: "chart.bar.fill")
                    }
                }
                
                // MARK: - Settings
                Section("Настройки") {
                    NavigationLink(destination: SettingsView()) {
                        Label("⚙️ Настройки пары", systemImage: "gearshape.fill")
                    }
                }
                
                // MARK: - About
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Разработчик")
                        Spacer()
                        Text("Our Love Team")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("💕 Не просто приложение для пар. Это место, где сохраняется история вашей любви.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Ещё")
        }
    }
    
    var daysTogether: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: settingsData.relationshipStartDate, to: Date())
        return max(components.day ?? 0, 0)
    }
}

// MARK: - Mood History View
struct MoodHistoryView: View {
    @Query private var moods: [MoodEntry]
    
    var sortedMoods: [MoodEntry] {
        moods.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Mood overview
                if !moods.isEmpty {
                    moodOverviewCard
                }
                
                // Mood history chart
                if !sortedMoods.isEmpty {
                    moodChartCard
                }
                
                // Mood list
                if !sortedMoods.isEmpty {
                    moodListCard
                } else {
                    emptyMoodView
                }
            }
            .padding()
        }
        .navigationTitle("Настроение")
        .background(
            LinearGradient(colors: [.purple.opacity(0.03), .pink.opacity(0.03)],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    
    private var moodOverviewCard: some View {
        VStack(spacing: 12) {
            Text("Среднее настроение")
                .font(.headline)
                .foregroundColor(.secondary)
            
            let avgMood = moods.map { Double($0.moodPartner1) }.reduce(0, +) / Double(max(moods.count, 1))
            Text(String(format: "%.1f", avgMood))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.purple)
            
            Text("из 5")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                moodStat("\(moods.count)", "Записей")
                moodStat("\(moods.filter { $0.moodPartner1 >= 4 }.count)", "Хороших дней")
                moodStat("\(moods.filter { $0.moodPartner1 <= 2 }.count)", "Плохих дней")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func moodStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.pink)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var moodChartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("История настроения")
                .font(.headline)
            
            // Simple bar chart
            let recentMoods = Array(sortedMoods.prefix(14)).reversed()
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(recentMoods.enumerated()), id: \.element.id) { index, mood in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(moodColor(mood.moodPartner1))
                            .frame(width: 18, height: CGFloat(mood.moodPartner1) * 12)
                        
                        Text(formattedDay(mood.date))
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 80)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var moodListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Все записи")
                .font(.headline)
            
            ForEach(sortedMoods) { mood in
                HStack(spacing: 12) {
                    Text(["😢","😔","😐","😊","🥰"][mood.moodPartner1 - 1])
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.date, style: .date)
                            .font(.subheadline.weight(.medium))
                        if let note = mood.notePartner1 {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= mood.moodPartner1 ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                if mood != sortedMoods.last {
                    Divider()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var emptyMoodView: some View {
        VStack(spacing: 16) {
            Image(systemName: "face.smiling")
                .font(.system(size: 50))
                .foregroundStyle(.purple.opacity(0.5))
            
            Text("Нет записей настроения")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Отмечайте своё настроение каждый вечер,\nчтобы видеть историю эмоций")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func moodColor(_ value: Int) -> Color {
        switch value {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .purple
        default: return .gray
        }
    }
    
    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    MoreView()
        .modelContainer(for: [RelationshipSettings.self, MoodEntry.self], inMemory: true)
}
