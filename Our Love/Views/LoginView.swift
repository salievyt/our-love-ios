import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @StateObject private var authService = AuthServiceImpl(authRepo: DIContainer.shared.authRepository)
    
    @State private var isLogin = true
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("Our Love")
                            .font(.title.weight(.bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                    }
                    
                    // Form
                    VStack(spacing: 16) {
                        Text(isLogin ? "Вход" : "Регистрация")
                            .font(.title2.weight(.semibold))
                        
                        VStack(spacing: 12) {
                            TextField("Имя пользователя", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                            
                            SecureField("Пароль", text: $password)
                                .textFieldStyle(.roundedBorder)
                            
                            if !isLogin {
                                TextField("Email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                        }
                        
                        if let error = authService.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            Task {
                                if isLogin {
                                    await authService.login(username: username, password: password)
                                } else {
                                    await authService.register(
                                        username: username,
                                        password: password,
                                        email: email,
                                        inviteCode: nil
                                    )
                                }
                            }
                        } label: {
                            Text(isLogin ? "Войти" : "Зарегистрироваться")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(username.isEmpty || password.isEmpty || authService.isLoading)
                        
                        Button {
                            isLogin.toggle()
                        } label: {
                            Text(isLogin
                                ? "Нет аккаунта? Зарегистрироваться"
                                : "Уже есть аккаунт? Войти"
                            )
                            .font(.subheadline)
                            .foregroundColor(.pink)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [
                        .pink.opacity(0.05),
                        .purple.opacity(0.05),
                        .blue.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    LoginView()
}