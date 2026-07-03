import Foundation
import SwiftUI
import Combine

// MARK: - Home ViewModel

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var homeData: HomeData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let homeUseCase: HomeUseCaseType
    private let dateUseCase: DateUseCaseType
    
    init(homeUseCase: HomeUseCaseType, dateUseCase: DateUseCaseType) {
        self.homeUseCase = homeUseCase
        self.dateUseCase = dateUseCase
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            homeData = try await homeUseCase.fetchHomeData()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func saveMood(mood: Mood, note: String?) async {
        do {
            try await homeUseCase.saveMood(mood: mood, note: note)
            await loadData()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func daysUntilNext(from date: ImportantDate) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var nextDate: Date
        if date.isAnnually {
            let comps = calendar.dateComponents([.month, .day], from: date.date)
            let thisYear = calendar.component(.year, from: today)
            let thisYearDate = calendar.date(from: DateComponents(
                year: thisYear, month: comps.month ?? 1, day: comps.day ?? 1
            )) ?? date.date
            
            if thisYearDate < today {
                nextDate = calendar.date(from: DateComponents(
                    year: thisYear + 1, month: comps.month ?? 1, day: comps.day ?? 1
                )) ?? date.date
            } else {
                nextDate = thisYearDate
            }
        } else {
            nextDate = date.date
        }
        
        let days = calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
        if days <= 0 { return "Сегодня" }
        if days == 1 { return "Завтра" }
        return "Через \(days) дн."
    }
}
