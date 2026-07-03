import Foundation
import SwiftUI
import Combine

// MARK: - Tasks ViewModel

@MainActor
final class TasksViewModel: ObservableObject {
    
    @Published var todayTask: DailyTask?
    @Published var taskHistory: [DailyTask] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var completedToday = false
    
    private let taskUseCase: TaskUseCaseType
    
    init(taskUseCase: TaskUseCaseType) {
        self.taskUseCase = taskUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            async let todayResult = taskUseCase.fetchTodayTask()
            async let historyResult = taskUseCase.fetchTasks(isCompleted: nil, dateAssigned: nil)
            
            let (todayTask, tasksResponse) = try await (todayResult, historyResult)
            self.todayTask = todayTask
            self.taskHistory = tasksResponse.results.filter { $0.id != todayTask?.id }
            self.completedToday = todayTask?.isCompleted ?? false
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func completeTask() async {
        guard let taskId = todayTask?.id else { return }
        do {
            let updated = try await taskUseCase.completeTask(id: taskId)
            self.todayTask = updated
            self.completedToday = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func generateNewTask() async {
        do {
            let newTask = try await taskUseCase.generateTask()
            self.todayTask = newTask
            self.completedToday = false
        } catch {
            self.error = error.localizedDescription
        }
    }
}
