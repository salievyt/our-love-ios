import SwiftUI

// MARK: - Home View Backend

struct HomeViewBackend: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var authService: AuthServiceImpl
    @State private var showingMoodSheet = false
    @State private var showingNewDate = false
    @State private var selectedMood: Mood = .neutral
    @State private var moodNote = ""
    @State private var generatedInviteCode: String?
    @State private var copiedCode = false
    @State private var showingInviteInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else if let data = viewModel.homeData {
                    content(data: data)
                }
            }
            .background(
                LinearGradient(
                    colors: [.pink.opacity(0.05), .purple.opacity(0.05), .blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Our Love")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewDate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.pink)
                    }
                }
            }
            .sheet(isPresented: $showingMoodSheet) {
                moodSheetView
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Content
    @ViewBuilder
    private func content(data: HomeData) -> some View {
        VStack(spacing: 20) {
            // Invite partner card (only if no partner)
            if authService.relationship?.partner2 == nil {
                invitePartnerCard
            }
            
            // Header with Relationship Counter
            headerSection(data)
            
            // Important Dates
            if !data.upcomingDates.isEmpty {
                upcomingDatesSection(data)
            }
            
            // Today's Task
            todayTaskSection(data)
            
            // Question of the Day
            todayQuestionSection(data)
            
            // Today's Mood
            todayMoodSection(data)
            
            // Quick Access
            quickAccessSection
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    // MARK: - Invite Partner Card
    private var invitePartnerCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .font(.title3)
                    .foregroundStyle(.pink)
                Text("Пригласить партнёра")
                    .font(.headline)
                Spacer()
            }
            
            if let code = generatedInviteCode {
                // Show generated code
                VStack(spacing: 12) {
                    Text("Ваш код приглашения")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(code)
                        .font(.system(.title2, design: .monospaced).weight(.bold))
                        .foregroundColor(.pink)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.pink.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("Поделитесь этим кодом с партнёром.\nОн введёт его при регистрации.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        UIPasteboard.general.string = code
                        copiedCode = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedCode = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: copiedCode ? "checkmark" : "square.on.square")
                            Text(copiedCode ? "Скопировано!" : "Копировать код")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            } else {
                // Invite info
                Text("Пригласите вторую половинку, чтобы пользоваться приложением вместе!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingInviteInfo = true
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Как это работает?")
                    }
                    .font(.subheadline)
                    .foregroundColor(.pink)
                }
                
                Button {
                    Task {
                        let code = await authService.generateInviteCode()
                        if let code = code {
                            generatedInviteCode = code
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text("Сгенерировать код")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(authService.isLoading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 1
                        )
                )
                .shadow(color: .pink.opacity(0.08), radius: 12)
        )
        .sheet(isPresented: $showingInviteInfo) {
            inviteInfoSheet
        }
    }
    
    // MARK: - Invite Info Sheet
    private var inviteInfoSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.pink)
                
                Text("Как пригласить партнёра")
                    .font(.title2.weight(.semibold))
                
                VStack(alignment: .leading, spacing: 16) {
                    inviteStep(number: 1, text: "Нажмите «Сгенерировать код»")
                    inviteStep(number: 2, text: "Скопируйте полученный код")
                    inviteStep(number: 3, text: "Отправьте код партнёру")
                    inviteStep(number: 4, text: "Партнёр вводит код при регистрации")
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Приглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Понятно") { showingInviteInfo = false }
                }
            }
        }
    }
    
    private func inviteStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.pink)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
        }
    }
    
    // MARK: - Header
    private func headerSection(_ data: HomeData) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .padding(.top, 10)
            
            Text("\(data.daysTogether)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("дней вместе")
                .font(.title3.weight(.medium))
                .foregroundColor(.secondary)
            
            Text("с \(data.startDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .pink.opacity(0.1), radius: 15)
        )
    }
    
    // MARK: - Upcoming Dates
    private func upcomingDatesSection(_ data: HomeData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.pink)
                Text("Ближайшие даты")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(data.upcomingDates.prefix(3)) { date in
                HStack(spacing: 12) {
                    Text(date.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(date.title)
                            .font(.subheadline.weight(.medium))
                        
                        Text(date.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(daysUntilNext(from: date.date, isAnnually: date.isAnnually))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.pink.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
                
                if date != data.upcomingDates.prefix(3).last {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .pink.opacity(0.05), radius: 10)
        )
    }
    
    private func daysUntilNext(from date: Date, isAnnually: Bool) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var nextDate: Date
        if isAnnually {
            let comps = calendar.dateComponents([.month, .day], from: date)
            let thisYear = calendar.component(.year, from: today)
            let thisYearDate = calendar.date(from: DateComponents(
                year: thisYear, month: comps.month ?? 1, day: comps.day ?? 1
            )) ?? date
            
            if thisYearDate < today {
                nextDate = calendar.date(from: DateComponents(
                    year: thisYear + 1, month: comps.month ?? 1, day: comps.day ?? 1
                )) ?? date
            } else {
                nextDate = thisYearDate
            }
        } else {
            nextDate = date
        }
        
        let days = calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
        if days <= 0 { return "Сегодня" }
        if days == 1 { return "Завтра" }
        return "Через \(days) дн."
    }
    
    // MARK: - Today's Task
    private func todayTaskSection(_ data: HomeData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.orange)
                Text("Задание дня")
                    .font(.headline)
                Spacer()
                
                if let task = data.todayTask, !task.isCompleted {
                    NavigationLink(destination: TasksViewBackend()) {
                        Text("Выполнить →")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.pink)
                    }
                }
            }
            
            if let task = data.todayTask {
                HStack(spacing: 14) {
                    Text(task.emoji)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(.orange.opacity(0.5))
                    }
                }
            } else {
                HStack {
                    Image(systemName: "target")
                        .font(.title)
                        .foregroundStyle(.orange)
                        .frame(width: 50, height: 50)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("Сегодня нет задания. Отдохните вместе!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .orange.opacity(0.05), radius: 10)
        )
    }
    
    // MARK: - Question of the Day
    private func todayQuestionSection(_ data: HomeData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.bubble")
                    .foregroundStyle(.blue)
                Text("Вопрос дня")
                    .font(.headline)
                Spacer()
                
                NavigationLink(destination: QuestionsViewBackend()) {
                    Text("Ответить →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                }
            }
            
            if let question = data.todayQuestion {
                VStack(spacing: 10) {
                    Text(question.question)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 20) {
                        Label(question.partner1Answered ? "Ответили" : "Ожидаем",
                              systemImage: question.partner1Answered ? "checkmark.circle.fill" : "hourglass")
                            .font(.caption)
                            .foregroundColor(question.partner1Answered ? .green : .orange)
                        
                        Label(question.partner2Answered ? "Ответили" : "Ожидаем",
                              systemImage: question.partner2Answered ? "checkmark.circle.fill" : "hourglass")
                            .font(.caption)
                            .foregroundColor(question.partner2Answered ? .green : .orange)
                    }
                }
            } else {
                Text("Сегодня нет вопроса. Наслаждайтесь моментом!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .blue.opacity(0.05), radius: 10)
        )
    }
    
    // MARK: - Today's Mood
    private func todayMoodSection(_ data: HomeData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundStyle(.purple)
                Text("Настроение сегодня")
                    .font(.headline)
                Spacer()
                
                Button {
                    showingMoodSheet = true
                } label: {
                    Text(data.todayMood != nil ? "Изменить" : "Отметить →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                }
            }
            
            if let mood = data.todayMood {
                HStack(spacing: 16) {
                    Image(systemName: mood.mood.sfSymbol)
                        .font(.system(size: 40))
                        .foregroundStyle(moodColor(mood.mood))
                    
                    VStack(alignment: .leading) {
                        Text(moodText(for: mood.mood))
                            .font(.subheadline.weight(.medium))
                        if let note = mood.note {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= mood.mood.rawValue ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            } else {
                Button {
                    showingMoodSheet = true
                } label: {
                    HStack {
                        Image(systemName: "face.smiling")
                            .font(.title)
                            .foregroundStyle(.purple)
                        Text("Нажмите, чтобы отметить настроение")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .purple.opacity(0.05), radius: 10)
        )
    }
    
    // MARK: - Quick Access
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрый доступ")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                quickLink(icon: "map", title: "Карта", destination: MapViewBackend())
                quickLink(icon: "clock.arrow.2.circlepath", title: "Капсула", destination: TimeCapsuleViewBackend())
                quickLink(icon: "paintpalette", title: "Постеры", destination: PosterGeneratorViewBackend())
                quickLink(icon: "book", title: "Дневник", destination: DiaryViewBackend())
                quickLink(icon: "chart.bar", title: "Статистика", destination: MoreViewBackend())
                quickLink(icon: "camera", title: "Альбом", destination: AlbumViewBackend())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .primary.opacity(0.03), radius: 10)
        )
    }
    
    private func quickLink<Destination: View>(icon: String, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Mood Sheet
    private var moodSheetView: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Как прошёл твой день?")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 30)
                
                Image(systemName: selectedMood.sfSymbol)
                    .font(.system(size: 80))
                    .foregroundStyle(moodColor(selectedMood))
                
                HStack(spacing: 8) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button {
                            selectedMood = mood
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: mood.sfSymbol)
                                    .font(.system(size: 30))
                                    .foregroundStyle(moodColor(mood))
                                Text(moodText(for: mood))
                                    .font(.caption2)
                                    .foregroundColor(selectedMood == mood ? .pink : .secondary)
                            }
                            .padding(8)
                            .background(selectedMood == mood ? Color.pink.opacity(0.1) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.saveMood(mood: selectedMood, note: moodNote)
                        showingMoodSheet = false
                    }
                } label: {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .presentationDetents([.height(400)])
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Ошибка загрузки")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Повторить") {
                Task {
                    await viewModel.loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func moodText(for value: Mood) -> String {
        value.label
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
}

#Preview {
    HomeViewBackend()
        .environmentObject(HomeViewModel(
            homeUseCase: DIContainer.shared.homeUseCase,
            dateUseCase: DIContainer.shared.dateUseCase
        ))
}
