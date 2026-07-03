import SwiftUI

// MARK: - More View Backend

struct MoreViewBackend: View {
    @EnvironmentObject var viewModel: MoreViewModel
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 20) {
                        // Relationship Info
                        relationshipInfoSection
                        
                        // Stats
                        statsSection
                        
                        // Features
                        featuresSection
                        
                        // Settings
                        settingsSection
                        
                        // About
                        aboutSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Ещё")
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Relationship Info
    private var relationshipInfoSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("\(viewModel.daysTogether)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("дней вместе")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !viewModel.partner1Name.isEmpty {
                Text("\(viewModel.partner1Name) & \(viewModel.partner2Name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Stats
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(icon: "face.smiling", value: "\(viewModel.moods.count)", label: "Настроений")
                statCard(icon: "target", value: "\(viewModel.taskCount)", label: "Заданий")
                statCard(icon: "camera", value: "\(viewModel.photoCount)", label: "Фото")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.pink)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.pink)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Features
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Разделы")
                .font(.headline)
            
            featureRow(icon: "face.smiling", title: "Настроение", destination: MoodHistoryViewBackend())
            featureRow(icon: "map", title: "Карта отношений", destination: MapViewBackend())
            featureRow(icon: "clock.arrow.2.circlepath", title: "Капсула времени", destination: TimeCapsuleViewBackend())
            featureRow(icon: "paintpalette", title: "Генератор постеров", destination: PosterGeneratorViewBackend())
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func featureRow<Destination: View>(icon: String, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.pink)
                    .frame(width: 36, height: 36)
                    .background(.pink.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Settings
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Настройки")
                .font(.headline)
            
            Button {
                showingLogoutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "door.left.hand.open")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .frame(width: 36, height: 36)
                        .background(.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("Выйти из аккаунта")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("Выход", isPresented: $showingLogoutConfirmation) {
            Button("Выйти", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите выйти?")
        }
    }
    
    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О приложении")
                .font(.headline)
            
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
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                Text("Не просто приложение для пар. Это место, где сохраняется история вашей любви.")
            }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Mood History View Backend

struct MoodHistoryViewBackend: View {
    @EnvironmentObject var viewModel: MoreViewModel
    
    var sortedMoods: [MoodEntry] {
        viewModel.moods.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Mood overview
                if !viewModel.moods.isEmpty {
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
        .task {
            await viewModel.loadData()
        }
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
            
            if let stats = viewModel.moodStats {
                Text(String(format: "%.1f", stats.averageMood))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
                
                Text("из 5")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    moodStat("\(stats.totalEntries)", "Записей")
                    moodStat("\(stats.distribution.filter { $0.key.rawValue >= 4 }.values.reduce(0, +))", "Хороших дней")
                    moodStat("\(stats.distribution.filter { $0.key.rawValue <= 2 }.values.reduce(0, +))", "Плохих дней")
                }
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
            
            let recentMoods = Array(sortedMoods.prefix(14)).reversed()
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(recentMoods.enumerated()), id: \.element.id) { index, mood in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(moodColor(mood.mood))
                            .frame(width: 18, height: CGFloat(mood.mood.rawValue) * 12)
                        
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
                    Image(systemName: mood.mood.sfSymbol)
                        .font(.title2)
                        .foregroundStyle(moodColor(mood.mood))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.date, style: .date)
                            .font(.subheadline.weight(.medium))
                        if let note = mood.note {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= mood.mood.rawValue ? "star.fill" : "star")
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
    
    private func moodColor(_ value: Mood) -> Color {
        switch value {
        case .sad: return .red
        case .down: return .orange
        case .neutral: return .yellow
        case .happy: return .green
        case .loved: return .purple
        }
    }
    
    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    MoreViewBackend()
        .environmentObject(MoreViewModel(
            moodUseCase: DIContainer.shared.moodUseCase,
            authService: DIContainer.shared.authService,
            albumUseCase: DIContainer.shared.albumUseCase,
            diaryUseCase: DIContainer.shared.diaryUseCase,
            taskUseCase: DIContainer.shared.taskUseCase
        ))
}
