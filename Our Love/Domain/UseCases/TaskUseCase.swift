import Foundation

// MARK: - Task Use Case Protocol

protocol TaskUseCaseType {
    func fetchTodayTask() async throws -> DailyTask?
    func fetchTasks(isCompleted: Bool?, dateAssigned: Date?) async throws -> PaginatedResponse<DailyTask>
    func completeTask(id: String) async throws -> DailyTask
    func generateTask() async throws -> DailyTask
}

// MARK: - Task Use Case

final class TaskUseCase: TaskUseCaseType {
    
    private let taskRepo: TaskRepositoryProtocol
    
    init(taskRepo: TaskRepositoryProtocol) {
        self.taskRepo = taskRepo
    }
    
    func fetchTodayTask() async throws -> DailyTask? {
        try await taskRepo.fetchTodayTask()
    }
    
    func fetchTasks(isCompleted: Bool? = nil, dateAssigned: Date? = nil) async throws -> PaginatedResponse<DailyTask> {
        try await taskRepo.fetchTasks(
            isCompleted: isCompleted,
            dateAssigned: dateAssigned,
            page: nil,
            search: nil,
            ordering: nil
        )
    }
    
    func completeTask(id: String) async throws -> DailyTask {
        try await taskRepo.completeTask(id: id)
    }
    
    func generateTask() async throws -> DailyTask {
        try await taskRepo.generateTask()
    }
}
