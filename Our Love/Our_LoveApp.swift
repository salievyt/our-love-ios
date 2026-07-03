import SwiftUI

@main
struct Our_LoveApp: App {
    @StateObject private var authService = AuthServiceImpl(authRepo: DIContainer.shared.authRepository)
    @State private var showProfileSetup = false
    @State private var showPartnerSearch = false
    @State private var showMainApp = false
    @State private var isCheckingProfile = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    if isCheckingProfile {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.pink)
                            Text("Загрузка...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.pink.opacity(0.03), .purple.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
                        )
                        .task {
                            await checkPartnerProfile()
                            isCheckingProfile = false
                        }
                    } else if showMainApp {
                        MainTabViewBackend()
                            .environmentObject(authService)
                    } else if showPartnerSearch {
                        PartnerSearchView(onGoHome: {
                            showMainApp = true
                            showPartnerSearch = false
                            showProfileSetup = false
                        })
                        .environmentObject(authService)
                    } else if showProfileSetup {
                        ProfileSetupView(
                            onProfileCreated: {
                                showPartnerSearch = true
                                showProfileSetup = false
                            },
                            onSkipped: {
                                showMainApp = true
                                showProfileSetup = false
                            }
                        )
                        .environmentObject(authService)
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
    
    private func checkPartnerProfile() async {
        let api = PartnerAPI()
        do {
            let profile = try await api.getMyProfile()
            if !profile.isActive {
                showProfileSetup = true
            }
        } catch {
            // No profile exists yet - show setup
            showProfileSetup = true
        }
    }
}
