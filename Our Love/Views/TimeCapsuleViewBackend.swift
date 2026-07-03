import SwiftUI

// MARK: - Time Capsule View Backend

struct TimeCapsuleViewBackend: View {
    @EnvironmentObject var viewModel: TimeCapsuleViewModel
    @State private var showingNewCapsule = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else {
                    VStack(spacing: 20) {
                        // Hero section
                        heroSection
                        
                        // Active capsules
                        if !viewModel.activeCapsules.isEmpty {
                            activeCapsulesSection
                        }
                        
                        // Opened capsules
                        if !viewModel.openedCapsules.isEmpty {
                            openedCapsulesSection
                        }
                        
                        // Empty state
                        if viewModel.activeCapsules.isEmpty && viewModel.openedCapsules.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(
                LinearGradient(colors: [.purple.opacity(0.03), .blue.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Капсула времени")
            .task {
                await viewModel.loadData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewCapsule = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingNewCapsule) {
                NewCapsuleViewBackend()
            }
        }
    }
    
    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.2.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Послание в будущее")
                .font(.title2.weight(.bold))
            
            Text("Напишите письмо себе и своей половинке,\nкоторое откроется в особенный день")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !viewModel.activeCapsules.isEmpty {
                Text("\(viewModel.activeCapsules.count) капсул\(viewModel.activeCapsules.count == 1 ? "а" : "ы") ожидают")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(.purple.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Active Capsules
    private var activeCapsulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ожидают открытия")
                .font(.headline)
            
            ForEach(viewModel.activeCapsules) { capsule in
                NavigationLink(destination: CapsuleDetailViewBackend(capsule: capsule)) {
                    capsuleRow(capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func capsuleRow(_ capsule: TimeCapsule) -> some View {
        HStack(spacing: 14) {
            Image(systemName: capsule.isReadyToOpen ? "envelope.open.fill" : "envelope.fill")
                .font(.title2)
                .foregroundStyle(capsule.isReadyToOpen ? .green : .purple)
                .frame(width: 40, height: 40)
                .background((capsule.isReadyToOpen ? Color.green : Color.purple).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(capsule.title)
                    .font(.subheadline.weight(.medium))
                
                if capsule.isReadyToOpen {
                    Label("Можно открыть!", systemImage: "party.popper.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Откроется \(capsule.openDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if capsule.isReadyToOpen {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Opened Capsules
    private var openedCapsulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Открытые")
                .font(.headline)
            
            ForEach(viewModel.openedCapsules) { capsule in
                NavigationLink(destination: CapsuleDetailViewBackend(capsule: capsule)) {
                    HStack(spacing: 14) {
                        Image(systemName: "envelope.open")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 40)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(capsule.title)
                                .font(.subheadline.weight(.medium))
                            Text("Открыто \(capsule.openedAt ?? capsule.createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 50))
                .foregroundStyle(.purple.opacity(0.5))
            
            Text("Нет капсул времени")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                showingNewCapsule = true
            } label: {
                Label("Создать первую", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
}

// MARK: - New Capsule View Backend

struct NewCapsuleViewBackend: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: TimeCapsuleViewModel
    
    @State private var title = ""
    @State private var message = ""
    @State private var openDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("О капсуле") {
                    TextField("Название", text: $title)
                    DatePicker("Дата открытия", selection: $openDate, displayedComponents: .date)
                }
                
                Section("Послание") {
                    TextEditor(text: $message)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Новая капсула")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        saveCapsule()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
        }
    }
    
    private func saveCapsule() {
        Task {
            await viewModel.createCapsule(title: title, message: message, openDate: openDate)
        }
    }
}

// MARK: - Capsule Detail View Backend

struct CapsuleDetailViewBackend: View {
    let capsule: TimeCapsule
    @EnvironmentObject var viewModel: TimeCapsuleViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: capsule.isOpened ? "envelope.open.fill" : "envelope.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(capsule.isOpened ? AnyShapeStyle(Color.secondary) : AnyShapeStyle(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)))
                
                Text(capsule.title)
                    .font(.title2.weight(.bold))
                
                if capsule.isOpened {
                    // Show content
                    Text(capsule.message)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Text("Создано \(capsule.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if capsule.isReadyToOpen {
                    // Ready to open
                    Label("Эта капсула готова к открытию!", systemImage: "party.popper.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button {
                        Task {
                            await viewModel.openCapsule(id: capsule.id)
                            dismiss()
                        }
                    } label: {
                        Label("Открыть капсулу", systemImage: "envelope.open")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    // Waiting
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                        
                        Text("Капсула запечатана до \(capsule.openDate, style: .date)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Осталось \(capsule.daysUntilOpen) дней")
                            .font(.subheadline)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(.purple.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Капсула")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(colors: [.purple.opacity(0.03), .blue.opacity(0.03)],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    TimeCapsuleViewBackend()
        .environmentObject(TimeCapsuleViewModel(capsuleUseCase: DIContainer.shared.capsuleUseCase))
}