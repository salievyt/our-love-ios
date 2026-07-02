//  TasksView.swift
//  Our Love

import SwiftUI
import SwiftData
import PhotosUI

struct TasksView: View {
    @Query private var tasks: [DailyTask]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedTask: DailyTask?
    @State private var showingCompletionSheet = false
    
    static let taskTemplates: [(title: String, description: String, emoji: String)] = [
        ("Сходить в кафе", "Посетите новое или любимое кафе вдвоём. Насладитесь атмосферой и друг другом.", "☕️"),
        ("Посмотреть закат", "Найдите красивое место, чтобы вместе встретить закат солнца.", "🌅"),
        ("Сделать совместное фото", "Сделайте креативное совместное фото на память об этом дне.", "📸"),
        ("Посетить новое место", "Откройте для себя новое место в вашем городе или районе.", "🗺"),
        ("Приготовить ужин вместе", "Приготовьте что-то вкусное вместе. Это может быть новое блюдо!", "🍳"),
        ("Устроить киновечер", "Выберите фильм для совместного просмотра с попкорном и пледами.", "🎬"),
        ("Написать письмо любви", "Напишите друг другу письма и обменяйтесь ими.", "💌"),
        ("Сделать зарядку вместе", "Проведите небольшую совместную тренировку.", "🏃"),
        ("Поиграть в настольную игру", "Проведите время за настольной игрой или пазлом.", "🎲"),
        ("Прогуляться в парке", "Совершите неспешную прогулку в парке или лесу.", "🌳"),
        ("Послушать музыку", "Составьте совместный плейлист и послушайте его вместе.", "🎵"),
        ("Сделать массаж друг другу", "Расслабьтесь и сделайте друг другу массаж.", "💆"),
        ("Посмотреть на звёзды", "Ночью выберитесь на природу или балкон и смотрите на звёзды.", "⭐️"),
        ("Потанцевать вместе", "Включите любимую музыку и потанцуйте дома или на улице.", "💃"),
        ("Сходить в музей", "Посетите музей или выставку, чтобы получить новые впечатления.", "🏛"),
        ("Устроить пикник", "Организуйте пикник в парке или на природе.", "🧺"),
        ("Прочитать книгу вслух", "Выберите книгу и почитайте её друг другу вслух.", "📚"),
        ("Испечь пирог", "Испеките вместе что-нибудь вкусное — пирог, печенье или кексы.", "🥧"),
        ("Посмотреть альбом с фото", "Пересмотрите старые совместные фотографии и вспомните моменты.", "🖼"),
        ("Покататься на велосипедах", "Если погода хорошая, покатайтесь на велосипедах или самокатах.", "🚲"),
        ("Сделать план на месяц", "Сядьте и вместе спланируйте интересные дела на следующий месяц.", "📋"),
        ("Устроить день без телефонов", "Проведите целый день без гаджетов, только вы вдвоём.", "📵"),
        ("Написать капсулу времени", "Напишите письмо себе из будущего и сохраните его.", "⏳"),
        ("Сходить на танцы", "Посетите танцевальный мастер-класс или просто потанцуйте.", "💃"),
    ]
    
    var sortedTasks: [DailyTask] {
        tasks.sorted(by: { $0.dateAssigned > $1.dateAssigned })
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // New task button
                    newTaskSection
                    
                    // Today's task highlight
                    if let todayTask = todayTask {
                        todayTaskCard(todayTask)
                    }
                    
                    // Task history
                    if !sortedTasks.isEmpty {
                        taskHistorySection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.orange.opacity(0.03), .yellow.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Задания")
            .sheet(item: $selectedTask) { task in
                completeTaskSheet(task: task)
            }
        }
    }
    
    private var todayTask: DailyTask? {
        let today = Calendar.current.startOfDay(for: Date())
        return tasks.first { Calendar.current.isDate($0.dateAssigned, inSameDayAs: today) }
    }
    
    // MARK: - New Task
    private var newTaskSection: some View {
        Button {
            generateRandomTask()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title3)
                Text("Сгенерировать новое задание")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(todayTask != nil)
        .opacity(todayTask != nil ? 0.5 : 1)
    }
    
    // MARK: - Today's Task Card
    private func todayTaskCard(_ task: DailyTask) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(task.emoji)
                    .font(.system(size: 48))
                    .frame(width: 70, height: 70)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Задание дня")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.orange)
                    Text(task.title)
                        .font(.title3.weight(.bold))
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if task.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Задание выполнено! 🎉")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    selectedTask = task
                } label: {
                    Label("Отметить выполненным", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Task History
    private var taskHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История заданий")
                .font(.headline)
            
            ForEach(sortedTasks) { task in
                HStack(spacing: 12) {
                    Text(task.emoji)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.subheadline.weight(.medium))
                        Text(task.dateAssigned, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "circle.dashed")
                            .foregroundStyle(.orange.opacity(0.5))
                    }
                }
                .padding(.vertical, 4)
                
                if task != sortedTasks.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Complete Task Sheet
    private func completeTaskSheet(task: DailyTask) -> some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(task.emoji)
                    .font(.system(size: 80))
                
                Text(task.title)
                    .font(.title2.weight(.bold))
                
                Text("Прикрепите фотографию, чтобы сохранить этот момент")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if let data = task.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    showingPhotoPicker = true
                    selectedTask = task
                } label: {
                    Label("Добавить фото", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    completeTask(task)
                } label: {
                    Label("Задание выполнено!", systemImage: "checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Выполнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { selectedTask = nil }
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                if let item = newItem {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            task.photoData = data
                            try? modelContext.save()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func generateRandomTask() {
        guard todayTask == nil else { return }
        let template = Self.taskTemplates.randomElement()!
        let task = DailyTask(
            title: template.title,
            taskDescription: template.description,
            emoji: template.emoji
        )
        modelContext.insert(task)
        try? modelContext.save()
    }
    
    private func completeTask(_ task: DailyTask) {
        task.isCompleted = true
        task.completedAt = Date()
        selectedTask = nil
        try? modelContext.save()
    }
}

#Preview {
    TasksView()
        .modelContainer(for: [DailyTask.self], inMemory: true)
}
