import Foundation

// MARK: - Task Repository Protocol

protocol TaskRepositoryProtocol {
    func fetchTodayTask() async throws -> DailyTask?
    func fetchTasks(isCompleted: Bool?, dateAssigned: Date?, page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<DailyTask>
    func fetchTask(id: String) async throws -> DailyTask
    func createTask(title: String, description: String, emoji: String, dateAssigned: Date) async throws -> DailyTask
    func updateTask(id: String, title: String, description: String, emoji: String, isCompleted: Bool?, completedAt: Date?, photo: Data?) async throws -> DailyTask
    func completeTask(id: String) async throws -> DailyTask
    func deleteTask(id: String) async throws
    func generateTask() async throws -> DailyTask
    func fetchTaskTemplates(page: Int?, search: String?, ordering: String?) async throws -> PaginatedResponse<TaskTemplate>
}
