import SwiftUI
import PhotosUI

// MARK: - Album View Backend

struct AlbumViewBackend: View {
    @EnvironmentObject var viewModel: AlbumViewModel
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPhotoDetail = false
    @State private var selectedPhoto: Photo?
    @State private var showingCaptionEditor = false
    @State private var captionText = ""
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isNetworkError {
                    noInternetView
                } else if viewModel.error != nil {
                    serverErrorView
                } else if viewModel.filteredPhotos.isEmpty && viewModel.collages.isEmpty {
                    emptyAlbumView
                } else {
                    contentView
                }
            }
            .background(
                LinearGradient(colors: [.blue.opacity(0.03), .purple.opacity(0.03)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Наш альбом")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingPhotoPicker = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let item = newItem, let data = try? await item.loadTransferable(type: Data.self) {
                        await viewModel.uploadPhoto(imageData: data, caption: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.pink)
            Text("Загружаем альбом...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if !viewModel.collages.isEmpty {
                    collagesSection
                }
                
                yearFilterSection
                
                if viewModel.filteredPhotos.isEmpty {
                    emptyAlbumView
                } else {
                    photoGrid
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - No Internet View
    private var noInternetView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Нет подключения")
                .font(.title2.weight(.semibold))
            
            Text("Проверьте интернет-соединение\nи попробуйте снова")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task { await viewModel.loadData() }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Server Error View
    private var serverErrorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .red], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Ошибка сервера")
                .font(.title2.weight(.semibold))
            
            if let errorMessage = viewModel.error {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button {
                Task { await viewModel.loadData() }
            } label: {
                Label("Попробовать снова", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.purple, .red], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Collages
    private var collagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "rectangle.3.group.fill")
                    .foregroundStyle(.purple)
                Text("Коллажи")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.collages.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.collages) { collage in
                        VStack {
                            if let imageURL = collage.imageURL,
                               let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 100)
                                    case .failure:
                                        placeholderCollage
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        placeholderCollage
                                    }
                                }
                            } else {
                                placeholderCollage
                            }
                            
                            Text(collage.title)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var placeholderCollage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: 140, height: 100)
            .overlay {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundStyle(.purple)
            }
    }
    
    // MARK: - Year Filter
    private var yearFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                yearChip(year: nil, label: "Все")
                
                ForEach(viewModel.availableYears, id: \.self) { year in
                    yearChip(year: year, label: "\(year)")
                }
            }
        }
    }
    
    private func yearChip(year: Int?, label: String) -> some View {
        Button {
            withAnimation(.spring()) {
                viewModel.selectedYear = year
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(viewModel.selectedYear == year ? .semibold : .regular))
                .foregroundColor(viewModel.selectedYear == year ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(viewModel.selectedYear == year ? AnyShapeStyle(Color.pink) : AnyShapeStyle(.ultraThinMaterial))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Empty State
    private var emptyAlbumView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("Ваш альбом пуст")
                    .font(.title2.weight(.semibold))
                
                Text("Начните добавлять совместные фотографии,\nчтобы сохранить воспоминания")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingPhotoPicker = true
                } label: {
                    Label("Добавить фото", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        }
    }
    
    // MARK: - Photo Grid
    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(viewModel.filteredPhotos) { photo in
                Button {
                    selectedPhoto = photo
                    showingPhotoDetail = true
                } label: {
                    if let url = URL(string: photo.imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: (UIScreen.main.bounds.width - 48) / 3)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            case .failure:
                                placeholderPhoto
                            case .empty:
                                ProgressView()
                                    .frame(height: (UIScreen.main.bounds.width - 48) / 3)
                            @unknown default:
                                placeholderPhoto
                            }
                        }
                    } else {
                        placeholderPhoto
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var placeholderPhoto: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.ultraThinMaterial)
            .frame(height: (UIScreen.main.bounds.width - 48) / 3)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
    
}

// MARK: - Photo Detail Sheet
struct PhotoDetailSheet: View {
    let photo: Photo
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AlbumViewModel
    @State private var editingCaption = false
    @State private var captionText: String
    
    init(photo: Photo) {
        self.photo = photo
        _captionText = State(initialValue: photo.caption ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let url = URL(string: photo.imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if editingCaption {
                            TextField("Добавьте описание...", text: $captionText)
                                .textFieldStyle(.roundedBorder)
                                .onDisappear {
                                    editingCaption = false
                                    if captionText != (photo.caption ?? "") {
                                        Task {
                                            await viewModel.updatePhoto(id: photo.id, caption: captionText)
                                        }
                                    }
                                }
                        } else {
                            Text(photo.caption ?? "Без описания")
                                .font(.subheadline)
                                .onTapGesture {
                                    editingCaption = true
                                }
                                .foregroundColor(.secondary)
                        }
                        
                        Text(formatDate(photo.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Удалить") {
                        Task {
                            await viewModel.deletePhoto(id: photo.id)
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AlbumViewBackend()
        .environmentObject(AlbumViewModel(albumUseCase: DIContainer.shared.albumUseCase))
}
