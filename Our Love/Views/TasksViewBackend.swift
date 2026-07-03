import SwiftUI

// MARK: - Tasks View Backend

struct TasksViewBackend: View {
    @EnvironmentObject var viewModel: TasksViewModel
    @State private var showingCompletionSheet = false
    
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
                        // New task button
                        newTaskSection
                        
                        // Today's task highlight
                        if let todayTask = viewModel.todayTask {
                            todayTaskCard(todayTask)
                        }
                        
                        // Task history
                        if !viewModel.taskHistory.isEmpty {
                            taskHistorySection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(
                LinearGradient(colors: [.orange.opacity(0.03), .yellow.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Задания")
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showingCompletionSheet) {
                if let task = viewModel.todayTask, !task.isCompleted {
                    completionSheet(task: task)
                }
            }
        }
    }
    
    // MARK: - New Task
    private var newTaskSection: some View {
        Button {
            Task {
                await viewModel.generateNewTask()
            }
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
        .disabled(viewModel.todayTask != nil)
        .opacity(viewModel.todayTask != nil ? 0.5 : 1)
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
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if task.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Image(systemName: "party.popper.fill")
                        .foregroundStyle(.yellow)
                    Text("Задание выполнено!")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    showingCompletionSheet = true
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
            
            ForEach(viewModel.taskHistory) { task in
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
                
                if task != viewModel.taskHistory.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Completion Sheet
    private func completionSheet(task: DailyTask) -> some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(task.emoji)
                    .font(.system(size: 80))
                
                Text(task.title)
                    .font(.title2.weight(.bold))
                
                Text("Отметьте задание как выполненное")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    Task {
                        await viewModel.completeTask()
                    }
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
                    Button("Закрыть") { showingCompletionSheet = false }
                }
            }
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
}

#Preview {
    TasksViewBackend()
        .environmentObject(TasksViewModel(taskUseCase: DIContainer.shared.taskUseCase))
}
