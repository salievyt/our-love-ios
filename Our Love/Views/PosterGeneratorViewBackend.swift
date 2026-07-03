import SwiftUI

// MARK: - Poster Generator View Backend

struct PosterGeneratorViewBackend: View {
    @EnvironmentObject var viewModel: PosterGeneratorViewModel
    @State private var showingPhotoPicker = false
    @State private var showingTemplatePicker = false
    @State private var selectedTemplate: PosterTemplate = .romantic
    
    let templates: [PosterTemplate] = [.romantic, .adventure, .funny, .minimal]
    
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
                        // Template selector
                        templatePicker
                        
                        // Photo section
                        photoSection
                        
                        // Preview
                        previewSection
                        
                        // Generate button
                        generateButton
                        
                        // Generated posters
                        if !viewModel.generatedPosters.isEmpty {
                            generatedPostersSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.03), .orange.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Постеры")
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showingTemplatePicker) {
                templatePickerSheet
            }
        }
    }
    
    // MARK: - Template Picker
    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Шаблон")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(templates, id: \.self) { template in
                        Button {
                            selectedTemplate = template
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: template.icon)
                                    .font(.title2)
                                    .foregroundStyle(template.iconColor)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedTemplate == template ? Color.pink.opacity(0.2) : Color.pink.opacity(0.05)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Text(template.title)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(selectedTemplate == template ? .pink : .secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Фото")
                .font(.headline)
            
            if let photo = viewModel.selectedPhoto {
                HStack {
                    if let url = URL(string: photo.imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text(photo.caption ?? "Без подписи")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        viewModel.selectedPhoto = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            } else {
                Button {
                    showingPhotoPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo")
                            .font(.title2)
                        Text("Выбрать фото из альбома")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Preview
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Предпросмотр")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: selectedTemplate.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: selectedTemplate.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(selectedTemplate.iconColor)
                        
                        if let photo = viewModel.selectedPhoto {
                            Text(photo.caption ?? "")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Выберите фото")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        HStack(spacing: 4) {
                            Text("Our Love")
                            Image(systemName: "heart.fill")
                        }
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generatePoster(template: selectedTemplate)
            }
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Сгенерировать постер")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.selectedPhoto == nil || viewModel.isLoading)
    }
    
    // MARK: - Generated Posters
    private var generatedPostersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сгенерированные")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.generatedPosters) { poster in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(colors: poster.template.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(height: 120)
                            .overlay {
                                Image(systemName: poster.template.icon)
                                    .font(.system(size: 30))
                                    .foregroundStyle(poster.template.iconColor)
                            }
                        
                        Text(poster.template.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Template Picker Sheet
    private var templatePickerSheet: some View {
        NavigationView {
            List {
                ForEach(templates, id: \.self) { template in
                    Button {
                        selectedTemplate = template
                        showingTemplatePicker = false
                    } label: {
                        HStack {
                            Image(systemName: template.icon)
                                .font(.title2)
                                .foregroundStyle(template.iconColor)
                            Text(template.title)
                                .font(.subheadline)
                            Spacer()
                            
                            if selectedTemplate == template {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Выберите шаблон")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { showingTemplatePicker = false }
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
    PosterGeneratorViewBackend()
        .environmentObject(PosterGeneratorViewModel(albumUseCase: DIContainer.shared.albumUseCase, authService: AuthServiceImpl(authRepo: DIContainer.shared.authRepository)))
}
