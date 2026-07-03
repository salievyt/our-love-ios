import SwiftUI

// MARK: - Partner Search View (Tinder-like)

struct PartnerSearchView: View {
    @EnvironmentObject var authService: AuthServiceImpl
    @StateObject private var viewModel = PartnerSearchViewModel()
    let onGoHome: (() -> Void)?
    @State private var showFilters = false
    @State private var showMatches = false
    
    init(onGoHome: (() -> Void)? = nil) {
        self.onGoHome = onGoHome
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isSearching && viewModel.profiles.isEmpty {
                    loadingView
                } else if let error = viewModel.error, viewModel.profiles.isEmpty {
                    errorView
                } else if viewModel.profiles.isEmpty {
                    emptyView
                } else if let profile = viewModel.currentProfile {
                    cardArea(profile: profile)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [.pink.opacity(0.03), .purple.opacity(0.03), .blue.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Поиск партнёра")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onGoHome?()
                    } label: {
                        Image(systemName: "house.fill")
                            .foregroundStyle(.pink)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.pink)
                        }
                        
                        Button {
                            showMatches = true
                        } label: {
                            ZStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                if !viewModel.matches.isEmpty {
                                    Text("\\(viewModel.matches.count)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadProfiles()
            }
            .sheet(isPresented: $showFilters) {
                filterSheet
            }
            .sheet(isPresented: $showMatches) {
                matchesSheet
            }
            .sheet(isPresented: $viewModel.showingMatch) {
                matchSheet
            }

        }
    }
    
    // MARK: - Card Area
    private func cardArea(profile: PartnerProfile) -> some View {
        VStack {
            Spacer()
            
            ZStack {
                // Stack cards
                ForEach(
                    Array(viewModel.profiles.dropFirst(viewModel.currentIndex).prefix(3).enumerated()),
                    id: \.element.id
                ) { index, p in
                    PartnerCardView(
                        profile: p,
                        onLike: { Task { await viewModel.likeCurrentProfile() } },
                        onPass: { Task { await viewModel.passCurrentProfile() } }
                    )
                    .scaleEffect(1 - CGFloat(index) * 0.05)
                    .offset(y: CGFloat(index) * 8)
                    .opacity(1 - Double(index) * 0.15)
                }
            }
            
            Spacer()
            
            // Bottom stats
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.secondary)
                Text("Осталось: \\(viewModel.profiles.count - viewModel.currentIndex)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.pink)
            Text("Ищем анкеты...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Анкеты закончились")
                .font(.title2.weight(.semibold))
            
            Text("Пока нет новых анкет в вашем городе.\\nПопробуйте изменить фильтры или зайдите позже.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.filterCity = ""
                viewModel.filterGender = ""
                Task { await viewModel.loadProfiles() }
            } label: {
                Label("Обновить", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Ошибка загрузки")
                .font(.title2.weight(.semibold))
            
            if let error = viewModel.error {
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task { await viewModel.loadProfiles() }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Filter Sheet
    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Город") {
                    TextField("Название города", text: $viewModel.filterCity)
                }
                
                Section("Пол") {
                    Picker("Пол", selection: $viewModel.filterGender) {
                        Text("Любой").tag("")
                        Text("Девушка").tag("female")
                        Text("Парень").tag("male")
                        Text("Другой").tag("other")
                    }
                }
                
                Button("Применить") {
                    showFilters = false
                    Task { await viewModel.loadProfiles() }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.pink)
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { showFilters = false }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        viewModel.filterCity = ""
                        viewModel.filterGender = ""
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .presentationDetents([.height(350)])
    }
    
    // MARK: - Matches Sheet
    private var matchesSheet: some View {
        NavigationStack {
            List {
                if viewModel.matches.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Пока нет взаимных симпатий")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.matches) { match in
                        HStack(spacing: 14) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(match.displayName)
                                    .font(.headline)
                                if let city = match.city {
                                    Text(city)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Взаимные симпатии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { showMatches = false }
                }
            }
            .task {
                await viewModel.loadMatches()
            }
        }
    }
    
    // MARK: - Match Sheet
    private var matchSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "sparkles.heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .purple, .blue], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("Это взаимно! 🎉")
                    .font(.title.weight(.bold))
                
                if let profile = viewModel.matchProfile {
                    VStack(spacing: 8) {
                        Text("Вам понравилась анкета")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(profile.displayName)
                            .font(.title2.weight(.semibold))
                        
                        if let age = profile.age {
                            Text("\\(age) лет")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text("Пригласите партнёра в приложение через код приглашения на главном экране!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    viewModel.dismissMatch()
                } label: {
                    Text("Продолжить поиск")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    PartnerSearchView()
        .environmentObject(AuthServiceImpl(authRepo: DIContainer.shared.authRepository))
}
