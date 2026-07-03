import SwiftUI

// MARK: - Diary View Backend

struct DiaryViewBackend: View {
    @EnvironmentObject var viewModel: DiaryViewModel
    @State private var showingNewEntry = false
    @State private var selectedEntry: DiaryEntry?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isNetworkError {
                    noInternetView
                } else if viewModel.error != nil {
                    serverErrorView
                } else if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.03), .orange.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Дневник")
            .task {
                await viewModel.loadData()
            }
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
                NewDiaryEntryViewBackend()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.pink)
            Text("Загружаем дневник...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        ScrollView(showsIndicators: false) {
            newEntryCard
                .padding(.horizontal)
                .padding(.bottom, 30)
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                todayEntryCard
                timelineSection
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - No Internet View
    private var noInternetView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Нет подключения")
                .font(.title2.weight(.semibold))
            
            Text("Проверьте интернет-соединение\nи попробуйте снова")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task { await viewModel.loadData() }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Server Error View
    private var serverErrorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Ошибка сервера")
                .font(.title2.weight(.semibold))
            
            if let errorMessage = viewModel.error {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button {
                Task { await viewModel.loadData() }
            } label: {
                Label("Попробовать снова", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Today's Entry Card
    @ViewBuilder
    private var todayEntryCard: some View {
        if let today = viewModel.entries.first {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Сегодня")
                        .font(.headline)
                    Spacer()
                    Text(today.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let note = today.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .lineLimit(3)
                }
                
                HStack(spacing: 16) {
                    if let mood = today.moodPartner1 {
                        Label("\(mood)/5", systemImage: "face.smiling")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    if today.photoURL != nil {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                NavigationLink(destination: DiaryEntryDetailView(entry: today)) {
                    Text("Подробнее →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pink)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
    
    // MARK: - Timeline
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Хроника")
                .font(.headline)
                .padding(.bottom, 16)
            
            ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                HStack(alignment: .top, spacing: 14) {
                    // Timeline line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(LinearGradient(colors: [.pink, .orange], startPoint: .top, endPoint: .bottom))
                            .frame(width: 12, height: 12)
                        
                        if index < viewModel.entries.count - 1 {
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
                                if let mood = entry.moodPartner1,
                                   let moodEnum = Mood(rawValue: mood) {
                                    Image(systemName: moodEnum.sfSymbol)
                                        .font(.caption)
                                        .foregroundStyle(.purple)
                                }
                                if entry.photoURL != nil {
                                    Image(systemName: "photo.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
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

#Preview {
    DiaryViewBackend()
        .environmentObject(DiaryViewModel(diaryUseCase: DIContainer.shared.diaryUseCase))
}

// MARK: - New Diary Entry View Backend

struct NewDiaryEntryViewBackend: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: DiaryViewModel
    
    @State private var note = ""
    @State private var mood: Int = 3
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дата")
                            .font(.headline)
                        
                        DatePicker("Дата записи", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Mood
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Настроение")
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            ForEach(Mood.allCases, id: \.self) { m in
                                Button {
                                    mood = m.rawValue
                                } label: {
                                    Image(systemName: m.sfSymbol)
                                        .font(.title2)
                                        .foregroundStyle(moodColor(m))
                                        .padding(8)
                                        .background(mood == m.rawValue ? Color.pink.opacity(0.2) : .clear)
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
        }
    }
    
    private func saveEntry() {
        dismiss()
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
                
                if let mood = entry.moodPartner1 {
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
