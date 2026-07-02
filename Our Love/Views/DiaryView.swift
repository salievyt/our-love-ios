//  DiaryView.swift
//  Our Love

import SwiftUI
import SwiftData
import PhotosUI

struct DiaryView: View {
    @Query private var diaryEntries: [DiaryEntry]
    @Query private var questions: [QuestionOfTheDay]
    @Query private var moods: [MoodEntry]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNewEntry = false
    @State private var selectedEntry: DiaryEntry?
    
    var sortedEntries: [DiaryEntry] {
        diaryEntries.sorted(by: { $0.date > $1.date })
    }
    
    var todayEntry: DiaryEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return diaryEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Today's entry prompt
                    if todayEntry == nil {
                        newEntryCard
                    } else {
                        todayEntryCard(todayEntry!)
                    }
                    
                    // Timeline
                    if !sortedEntries.isEmpty {
                        timelineSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.03), .orange.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Дневник")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.pink)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewDiaryEntryView()
            }
        }
    }
    
    // MARK: - New Entry Card
    private var newEntryCard: some View {
        Button {
            showingNewEntry = true
        } label: {
            VStack(spacing: 14) {
                Image(systemName: "book.and.pencil")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("Записать день")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Сохраните воспоминания, мысли и чувства этого дня")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - Today's Entry
    private func todayEntryCard(_ entry: DiaryEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Сегодня")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .lineLimit(3)
            }
            
            HStack(spacing: 16) {
                if let mood = entry.partner1Mood {
                    Label("\(mood)/5", systemImage: "face.smiling")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                if entry.photoData != nil {
                    Image(systemName: "photo")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            NavigationLink(destination: DiaryEntryDetailView(entry: entry)) {
                Text("Подробнее →")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.pink)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Timeline
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Хроника")
                .font(.headline)
                .padding(.bottom, 16)
            
            ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                HStack(alignment: .top, spacing: 14) {
                    // Timeline line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(LinearGradient(colors: [.pink, .orange], startPoint: .top, endPoint: .bottom))
                            .frame(width: 12, height: 12)
                        
                        if index < sortedEntries.count - 1 {
                            Rectangle()
                                .fill(.pink.opacity(0.2))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    
                    // Entry
                    NavigationLink(destination: DiaryEntryDetailView(entry: entry)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date, style: .date)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            if let note = entry.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            HStack(spacing: 8) {
                                if let mood = entry.partner1Mood {
                                    Text(["😢","😔","😐","😊","🥰"][mood-1])
                                        .font(.caption)
                                }
                                if entry.photoData != nil {
                                    Image(systemName: "photo.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                                if entry.partner1Answer != nil {
                                    Image(systemName: "bubble.left.fill")
                                        .font(.caption2)
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.bottom, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - New Diary Entry
struct NewDiaryEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var note = ""
    @Query private var todayMoods: [MoodEntry]
    @Query private var todayQuestions: [QuestionOfTheDay]
    @State private var selectedPhotoData: Data?
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var mood: Int = 3
    
    var todayMood: MoodEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return todayMoods.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    var todayQuestion: QuestionOfTheDay? {
        let today = Calendar.current.startOfDay(for: Date())
        return todayQuestions.first { Calendar.current.isDate($0.dateAssigned, inSameDayAs: today) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Настроение")
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { i in
                                Button {
                                    mood = i
                                } label: {
                                    Text(["😢","😔","😐","😊","🥰"][i-1])
                                        .font(.title2)
                                        .padding(8)
                                        .background(mood == i ? Color.pink.opacity(0.2) : .clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Запись")
                            .font(.headline)
                        
                        TextEditor(text: $note)
                            .frame(height: 150)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Photo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Фото дня")
                            .font(.headline)
                        
                        if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            showingPhotoPicker = true
                        } label: {
                            Label("Добавить фото", systemImage: "camera")
                                .font(.subheadline)
                                .foregroundColor(.pink)
                        }
                    }
                    
                    // Today's question
                    if let question = todayQuestion {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Вопрос дня")
                                .font(.headline)
                            Text(question.question)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.blue.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Новая запись")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveEntry()
                    }
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                if let item = newItem {
                    Task {
                        selectedPhotoData = try? await item.loadTransferable(type: Data.self)
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = DiaryEntry()
        entry.note = note
        entry.partner1Mood = mood
        entry.photoData = selectedPhotoData
        entry.partner1Answer = todayQuestion?.answerPartner1
        entry.partner2Answer = todayQuestion?.answerPartner2
        modelContext.insert(entry)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Diary Entry Detail
struct DiaryEntryDetailView: View {
    let entry: DiaryEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date header
                Text(entry.date, style: .date)
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if let mood = entry.partner1Mood {
                    HStack {
                        Spacer()
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= mood ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        }
                        Spacer()
                    }
                }
                
                if let data = entry.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                if let note = entry.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Запись")
                            .font(.headline)
                            .foregroundColor(.pink)
                        Text(note)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                if let answer1 = entry.partner1Answer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ответ на вопрос дня")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Text(answer1)
                            .font(.subheadline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.purple.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Запись")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(colors: [.pink.opacity(0.03), .orange.opacity(0.03)],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    DiaryView()
        .modelContainer(for: [DiaryEntry.self, QuestionOfTheDay.self, MoodEntry.self], inMemory: true)
}
