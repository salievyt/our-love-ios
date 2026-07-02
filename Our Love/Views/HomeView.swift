//  HomeView.swift
//  Our Love

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var settings: [RelationshipSettings]
    @Query private var importantDates: [ImportantDate]
    @Query private var dailyTasks: [DailyTask]
    @Query private var questions: [QuestionOfTheDay]
    @Query private var moods: [MoodEntry]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingMoodSheet = false
    @State private var showingNewDateSheet = false
    @State private var selectedMood = 3
    
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
        let startDate = settingsData.relationshipStartDate
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        return max(components.day ?? 0, 0)
    }
    
    var todayTask: DailyTask? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyTasks.first { task in
            Calendar.current.isDate(task.dateAssigned, inSameDayAs: today)
        }
    }
    
    var todayQuestion: QuestionOfTheDay? {
        let today = Calendar.current.startOfDay(for: Date())
        return questions.first { q in
            Calendar.current.isDate(q.dateAssigned, inSameDayAs: today)
        }
    }
    
    var upcomingDates: [ImportantDate] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return importantDates.filter { date in
            let dateComponents = calendar.dateComponents([.month, .day], from: date.date)
            let todayComponents = calendar.dateComponents([.month, .day], from: today)
            
            if date.isAnnually {
                let thisYearDate = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: today),
                    month: dateComponents.month ?? 1,
                    day: dateComponents.day ?? 1
                ))!
                return thisYearDate >= today
            }
            return date.date >= today
        }.sorted { a, b in
            if a.isAnnually {
                let aComps = calendar.dateComponents([.month, .day], from: a.date)
                let bComps = calendar.dateComponents([.month, .day], from: b.date)
                let todayComps = calendar.dateComponents([.month, .day], from: today)
                
                let aThisYear = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: today),
                    month: aComps.month ?? 1, day: aComps.day ?? 1
                ))!
                let bThisYear = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: today),
                    month: bComps.month ?? 1, day: bComps.day ?? 1
                ))!
                return aThisYear < bThisYear
            }
            return a.date < b.date
        }
    }
    
    var todayMood: MoodEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return moods.first { mood in
            Calendar.current.isDate(mood.date, inSameDayAs: today)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: - Header with Relationship Counter
                    headerSection
                    
                    // MARK: - Important Dates
                    if !upcomingDates.isEmpty {
                        upcomingDatesSection
                    }
                    
                    // MARK: - Today's Task
                    todayTaskSection
                    
                    // MARK: - Question of the Day
                    todayQuestionSection
                    
                    // MARK: - Today's Mood
                    todayMoodSection
                    
                    // MARK: - Quick Access
                    quickAccessSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
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
                        showingNewDateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.pink)
                    }
                }
            }
            .sheet(isPresented: $showingMoodSheet) {
                moodSheetView
            }
            .sheet(isPresented: $showingNewDateSheet) {
                newDateSheet
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("💕")
                .font(.system(size: 50))
                .padding(.top, 10)
            
            Text("\(daysTogether)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("дней вместе")
                .font(.title3.weight(.medium))
                .foregroundColor(.secondary)
            
            Text("с \(settingsData.relationshipStartDate, style: .date)")
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
    private var upcomingDatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.pink)
                Text("Ближайшие даты")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(upcomingDates.prefix(3)) { date in
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
                
                if date != upcomingDates.prefix(3).last {
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
            ))!
            
            if thisYearDate < today {
                nextDate = calendar.date(from: DateComponents(
                    year: thisYear + 1, month: comps.month ?? 1, day: comps.day ?? 1
                ))!
            } else {
                nextDate = thisYearDate
            }
        } else {
            nextDate = date
        }
        
        let days = calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
        if days == 0 { return "Сегодня" }
        if days == 1 { return "Завтра" }
        return "Через \(days) дн."
    }
    
    // MARK: - Today's Task
    private var todayTaskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.orange)
                Text("Задание дня")
                    .font(.headline)
                Spacer()
                
                if let task = todayTask, !task.isCompleted {
                    NavigationLink(destination: TasksView()) {
                        Text("Выполнить →")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.pink)
                    }
                }
            }
            
            if let task = todayTask {
                HStack(spacing: 14) {
                    Text(task.emoji)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(task.taskDescription)
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
                    Text("🎯")
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("Сегодня нет задания. Отдохните вместе! 💕")
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
    private var todayQuestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.bubble")
                    .foregroundStyle(.blue)
                Text("Вопрос дня")
                    .font(.headline)
                Spacer()
                
                NavigationLink(destination: QuestionsView()) {
                    Text("Ответить →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                }
            }
            
            if let question = todayQuestion {
                VStack(spacing: 10) {
                    Text(question.question)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 20) {
                        Label(question.answerPartner1 != nil ? "✅ Ответили" : "⏳ Ожидаем",
                              systemImage: question.answerPartner1 != nil ? "checkmark.circle.fill" : "hourglass")
                            .font(.caption)
                            .foregroundColor(question.answerPartner1 != nil ? .green : .orange)
                        
                        Label(question.answerPartner2 != nil ? "✅ Ответили" : "⏳ Ожидаем",
                              systemImage: question.answerPartner2 != nil ? "checkmark.circle.fill" : "hourglass")
                            .font(.caption)
                            .foregroundColor(question.answerPartner2 != nil ? .green : .orange)
                    }
                }
            } else {
                Text("Сегодня нет вопроса. Наслаждайтесь моментом! ✨")
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
    private var todayMoodSection: some View {
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
                    Text(todayMood != nil ? "Изменить" : "Отметить →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                }
            }
            
            if let mood = todayMood {
                HStack(spacing: 16) {
                    Text(moodEmoji(for: mood.moodPartner1))
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading) {
                        Text(moodText(for: mood.moodPartner1))
                            .font(.subheadline.weight(.medium))
                        if let note = mood.notePartner1 {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= mood.moodPartner1 ? "star.fill" : "star")
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
                        Text("😊")
                            .font(.title)
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
                quickLink(emoji: "🗺", title: "Карта", destination: MapView())
                quickLink(emoji: "⏳", title: "Капсула", destination: TimeCapsuleView())
                quickLink(emoji: "🎨", title: "Постеры", destination: PosterGeneratorView())
                quickLink(emoji: "❤️", title: "Даты", destination: DatesListView())
                quickLink(emoji: "📊", title: "Статистика", destination: StatisticsView())
                quickLink(emoji: "⚙️", title: "Настройки", destination: SettingsView())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .primary.opacity(0.03), radius: 10)
        )
    }
    
    private func quickLink<Destination: View>(emoji: String, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.title2)
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
                
                Text(moodEmoji(for: selectedMood))
                    .font(.system(size: 80))
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Button {
                            selectedMood = i
                        } label: {
                            VStack(spacing: 6) {
                                Text(moodEmoji(for: i))
                                    .font(.system(size: 30))
                                Text(moodText(for: i))
                                    .font(.caption2)
                                    .foregroundColor(selectedMood == i ? .pink : .secondary)
                            }
                            .padding(8)
                            .background(selectedMood == i ? Color.pink.opacity(0.1) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    saveMood()
                    showingMoodSheet = false
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
    
    private var newDateSheet: some View {
        NavigationView {
            NewDateView()
        }
    }
    
    // MARK: - Helpers
    private func moodEmoji(for value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🥰"
        default: return "😐"
        }
    }
    
    private func moodText(for value: Int) -> String {
        switch value {
        case 1: return "Ужасно"
        case 2: return "Плохо"
        case 3: return "Нормально"
        case 4: return "Хорошо"
        case 5: return "Прекрасно"
        default: return "Нормально"
        }
    }
    
    private func saveMood() {
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = todayMood {
            existing.moodPartner1 = selectedMood
        } else {
            let newMood = MoodEntry(moodPartner1: selectedMood, date: today)
            modelContext.insert(newMood)
        }
        try? modelContext.save()
    }
}

// MARK: - Placeholder Views for Quick Access
struct DatesListView: View {
    @Query private var importantDates: [ImportantDate]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(importantDates) { date in
                    HStack {
                        Text(date.emoji)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(date.title)
                                .font(.subheadline.weight(.medium))
                            Text(date.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if date.isAnnually {
                            Text("Ежегодно")
                                .font(.caption2)
                                .foregroundColor(.pink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.pink.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(importantDates[index])
                    }
                }
            }
            .navigationTitle("Важные даты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NewDateView()
            }
        }
    }
}

struct NewDateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    @State private var emoji = "❤️"
    @State private var isAnnually = true
    
    let emojis = ["❤️", "💍", "🎂", "🎉", "🌸", "🏖", "🎄", "🎊", "✈️", "🏠", "🎁", "💑"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Детали") {
                    TextField("Название события", text: $title)
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    Toggle("Повторять ежегодно", isOn: $isAnnually)
                }
                
                Section("Эмодзи") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojis, id: \.self) { emojiItem in
                            Text(emojiItem)
                                .font(.title2)
                                .padding(8)
                                .background(emoji == emojiItem ? Color.pink.opacity(0.2) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    emoji = emojiItem
                                }
                        }
                    }
                }
            }
            .navigationTitle("Новая дата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let newDate = ImportantDate(title: title, date: date, emoji: emoji, isAnnually: isAnnually)
                        modelContext.insert(newDate)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct StatisticsView: View {
    @Query private var moods: [MoodEntry]
    @Query private var tasks: [DailyTask]
    @Query private var photos: [SharedPhoto]
    @Query private var diaryEntries: [DiaryEntry]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    statCard(emoji: "😊", title: "Записей настроения", value: "\(moods.count)", color: .purple)
                    statCard(emoji: "🎯", title: "Выполнено заданий", value: "\(tasks.filter { $0.isCompleted }.count)", color: .orange)
                    statCard(emoji: "📸", title: "Совместных фото", value: "\(photos.count)", color: .blue)
                    statCard(emoji: "📖", title: "Дней в дневнике", value: "\(diaryEntries.count)", color: .pink)
                }
                .padding()
            }
            .navigationTitle("Статистика")
            .background(
                LinearGradient(colors: [.pink.opacity(0.03), .purple.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
    
    private func statCard(emoji: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SettingsView: View {
    @Query private var settings: [RelationshipSettings]
    @Environment(\.modelContext) private var modelContext
    
    @State private var partner1Name = ""
    @State private var partner2Name = ""
    @State private var startDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Партнёры") {
                    TextField("Имя первого партнёра", text: $partner1Name)
                    TextField("Имя второго партнёра", text: $partner2Name)
                }
                
                Section("Отношения") {
                    DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Сохранить") {
                        saveSettings()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.pink)
                }
            }
            .navigationTitle("Настройки")
            .onAppear {
                if !settings.isEmpty {
                    partner1Name = settings[0].partner1Name
                    partner2Name = settings[0].partner2Name
                    startDate = settings[0].relationshipStartDate
                }
            }
        }
    }
    
    private func saveSettings() {
        if settings.isEmpty {
            let newSettings = RelationshipSettings(partner1Name: partner1Name, partner2Name: partner2Name, relationshipStartDate: startDate)
            modelContext.insert(newSettings)
        } else {
            settings[0].partner1Name = partner1Name
            settings[0].partner2Name = partner2Name
            settings[0].relationshipStartDate = startDate
        }
        try? modelContext.save()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [RelationshipSettings.self, ImportantDate.self, DailyTask.self, QuestionOfTheDay.self, MoodEntry.self, DiaryEntry.self, Place.self, TimeCapsule.self, Collage.self, Item.self], inMemory: true)
}
