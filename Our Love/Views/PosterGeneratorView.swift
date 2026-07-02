//  PosterGeneratorView.swift
//  Our Love

import SwiftUI
import SwiftData

struct PosterGeneratorView: View {
    @Query private var settings: [RelationshipSettings]
    @Query private var photos: [SharedPhoto]
    @Query private var tasks: [DailyTask]
    @Query private var moods: [MoodEntry]
    @Query private var places: [Place]
    @Query private var diaryEntries: [DiaryEntry]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedPoster: PosterType = .days
    @State private var generatedImage: UIImage?
    @State private var showingShareSheet = false
    
    enum PosterType: String, CaseIterable {
        case days = "Дни вместе"
        case achievements = "Достижения"
        case map = "Карта"
        case stats = "Статистика"
        
        var icon: String {
            switch self {
            case .days: return "heart.fill"
            case .achievements: return "star.fill"
            case .map: return "map.fill"
            case .stats: return "chart.bar.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .days: return .pink
            case .achievements: return .orange
            case .map: return .green
            case .stats: return .blue
            }
        }
    }
    
    var settingsData: RelationshipSettings {
        if settings.isEmpty {
            let defaultSettings = RelationshipSettings()
            modelContext.insert(defaultSettings)
            return defaultSettings
        }
        return settings[0]
    }
    
    var daysTogether: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: settingsData.relationshipStartDate, to: Date())
        return max(components.day ?? 0, 0)
    }
    
    var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalPlaces: Int {
        places.count
    }
    
    var averageMood: Double {
        let moodValues = moods.map { $0.moodPartner1 }
        guard !moodValues.isEmpty else { return 0 }
        return Double(moodValues.reduce(0, +)) / Double(moodValues.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Poster type selector
                    VStack(spacing: 12) {
                        Text("Выберите тип постера")
                            .font(.headline)
                        
                        Picker("Тип постера", selection: $selectedPoster) {
                            ForEach(PosterType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.pink)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Generated poster
                    if let image = generatedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .pink.opacity(0.1), radius: 20)
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        // Preview of what the poster will look like
                        posterPreview
                    }
                    
                    // Generate button
                    Button {
                        generatePoster()
                    } label: {
                        Label("Сгенерировать постер", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.pink, .purple, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.03), .purple.opacity(0.03), .blue.opacity(0.03)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Постеры")
            .sheet(isPresented: $showingShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    // MARK: - Poster Preview
    private var posterPreview: some View {
        VStack(spacing: 16) {
            switch selectedPoster {
            case .days:
                daysPosterContent
            case .achievements:
                achievementsPosterContent
            case .map:
                mapPosterContent
            case .stats:
                statsPosterContent
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [selectedPoster.color.opacity(0.1), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(selectedPoster.color.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var daysPosterContent: some View {
        VStack(spacing: 12) {
            Text("💕")
                .font(.system(size: 50))
            Text("\(daysTogether)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.pink)
            Text("дней вместе")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("с \(settingsData.relationshipStartDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var achievementsPosterContent: some View {
        VStack(spacing: 16) {
            Text("🏆")
                .font(.system(size: 50))
            Text("Наши достижения")
                .font(.title2.weight(.bold))
            
            VStack(alignment: .leading, spacing: 10) {
                achievementRow(emoji: "🎯", text: "Выполнено заданий: \(completedTasks)")
                achievementRow(emoji: "📸", text: "Фотографий: \(photos.count)")
                achievementRow(emoji: "🗺", text: "Посещено мест: \(totalPlaces)")
                achievementRow(emoji: "📖", text: "Дней в дневнике: \(diaryEntries.count)")
            }
        }
    }
    
    private func achievementRow(emoji: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.title3)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
    
    private var mapPosterContent: some View {
        VStack(spacing: 12) {
            Text("🗺")
                .font(.system(size: 50))
            Text("Наша карта")
                .font(.title2.weight(.bold))
            
            if !places.isEmpty {
                ForEach(places.prefix(5)) { place in
                    HStack {
                        Text(place.emoji)
                        Text(place.title)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            } else {
                Text("Добавьте важные места на карту")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(places.count) мест\(places.count == 1 ? "о" : "а") сохранено")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statsPosterContent: some View {
        VStack(spacing: 12) {
            Text("📊")
                .font(.system(size: 50))
            Text("Наша статистика")
                .font(.title2.weight(.bold))
            
            HStack(spacing: 20) {
                statItem(value: "\(daysTogether)", label: "Дней вместе", color: .pink)
                statItem(value: String(format: "%.1f", averageMood), label: "Настроение", color: .purple)
            }
            
            HStack(spacing: 20) {
                statItem(value: "\(completedTasks)", label: "Заданий", color: .orange)
                statItem(value: "\(photos.count)", label: "Фото", color: .blue)
            }
        }
    }
    
    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Generate
    private func generatePoster() {
        let renderer = ImageRenderer(content: posterPreview)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            generatedImage = image
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PosterGeneratorView()
        .modelContainer(for: [RelationshipSettings.self, SharedPhoto.self, DailyTask.self, MoodEntry.self, Place.self, DiaryEntry.self, Collage.self, Item.self], inMemory: true)
}
