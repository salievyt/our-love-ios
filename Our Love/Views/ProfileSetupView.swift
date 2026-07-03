import SwiftUI

// MARK: - Profile Setup View

struct ProfileSetupView: View {
    @EnvironmentObject var authService: AuthServiceImpl
    let onProfileCreated: (() -> Void)?
    let onSkipped: (() -> Void)?
    @State private var displayName = ""
    @State private var bio = ""
    @State private var city = ""
    @State private var birthDate = {
        let cal = Calendar.current
        return cal.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    }()
    @State private var gender = "female"
    @State private var isLoading = false
    @State private var error: String?
    @State private var profileCreated = false
    @State private var skipped = false
    
    init(onProfileCreated: (() -> Void)? = nil, onSkipped: (() -> Void)? = nil) {
        self.onProfileCreated = onProfileCreated
        self.onSkipped = onSkipped
    }
    
    private let genders = [
        ("female", "Девушка"),
        ("male", "Парень"),
        ("other", "Другой")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("Создайте анкету")
                            .font(.title2.weight(.bold))
                        
                        Text("Заполните информацию о себе,\nчтобы найти вторую половинку")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Имя").font(.headline)
                            TextField("Как вас зовут?", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Пол").font(.headline)
                            HStack(spacing: 12) {
                                ForEach(genders, id: \.0) { g in
                                    Button {
                                        gender = g.0
                                    } label: {
                                        Text(g.1)
                                            .font(.subheadline.weight(gender == g.0 ? .semibold : .regular))
                                            .foregroundColor(gender == g.0 ? .white : .primary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(gender == g.0 ? Color.pink : Color(.systemGray6))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Дата рождения").font(.headline)
                            DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Город").font(.headline)
                            TextField("Ваш город", text: $city)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("О себе").font(.headline)
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task { await createProfile() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("Опубликовать анкету и начать поиск")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(displayName.isEmpty || isLoading)
                    
                    Button {
                        skipped = true
                    } label: {
                        Text("Пропустить")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [.pink.opacity(0.03), .purple.opacity(0.03), .blue.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: profileCreated) { _, created in
                if created { onProfileCreated?() }
            }
            .onChange(of: skipped) { _, skip in
                if skip { onSkipped?() }
            }
        }
    }
    
    private func createProfile() async {
        isLoading = true
        error = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthDateStr = dateFormatter.string(from: birthDate)
        
        do {
            let api = PartnerAPI()
            _ = try await api.createProfile(
                displayName: displayName,
                bio: bio.isEmpty ? nil : bio,
                city: city.isEmpty ? nil : city,
                birthDate: birthDateStr,
                gender: gender
            )
            profileCreated = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthServiceImpl(authRepo: DIContainer.shared.authRepository))
}
