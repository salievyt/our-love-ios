//  AlbumView.swift
//  Our Love

import SwiftUI
import SwiftData
import PhotosUI

struct AlbumView: View {
    @Query private var photos: [SharedPhoto]
    @Query private var collages: [Collage]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedYear: Int?
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCollageCreator = false
    @State private var searchText = ""
    
    var availableYears: [Int] {
        let years = Set(photos.map { $0.yearTag })
        return years.sorted(by: >)
    }
    
    var filteredPhotos: [SharedPhoto] {
        var result = photos
        if let year = selectedYear {
            result = result.filter { $0.yearTag == year }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.caption.localizedCaseInsensitiveContains(searchText) }
        }
        return result.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Collages section
                    if !collages.isEmpty {
                        collagesSection
                    }
                    
                    // Year filter
                    yearFilterSection
                    
                    // Photo grid
                    if filteredPhotos.isEmpty {
                        emptyAlbumView
                    } else {
                        photoGrid
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
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
                            showingCollageCreator = true
                        } label: {
                            Image(systemName: "rectangle.3.group")
                                .foregroundStyle(.purple)
                        }
                        
                        Button {
                            showingPhotoPicker = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                if let item = newItem {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            let photo = SharedPhoto(imageData: data, caption: "")
                            modelContext.insert(photo)
                            try? modelContext.save()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCollageCreator) {
                CollageCreatorView()
            }
        }
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
                Text("\(collages.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(collages) { collage in
                        VStack {
                            if let data = collage.photoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 140, height: 100)
                                    .overlay {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.title2)
                                            .foregroundStyle(.purple)
                                    }
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
    
    // MARK: - Year Filter
    private var yearFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                yearChip(year: nil, label: "Все")
                
                ForEach(availableYears, id: \.self) { year in
                    yearChip(year: year, label: "\(year)")
                }
            }
        }
    }
    
    private func yearChip(year: Int?, label: String) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedYear = year
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(selectedYear == year ? .semibold : .regular))
                .foregroundColor(selectedYear == year ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedYear == year ? AnyShapeStyle(Color.pink) : AnyShapeStyle(.ultraThinMaterial))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Empty State
    private var emptyAlbumView: some View {
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
    
    // MARK: - Photo Grid
    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(filteredPhotos) { photo in
                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                    if let data = photo.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: (UIScreen.main.bounds.width - 48) / 3)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .frame(height: (UIScreen.main.bounds.width - 48) / 3)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Photo Detail
struct PhotoDetailView: View {
    @Bindable var photo: SharedPhoto
    @Environment(\.dismiss) private var dismiss
    @State private var editedCaption = ""
    
    var body: some View {
        VStack(spacing: 16) {
            if let data = photo.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Добавьте описание...", text: $editedCaption)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .onSubmit {
                        photo.caption = editedCaption
                        try? photo.modelContext?.save()
                    }
                
                Text(photo.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedCaption = photo.caption
        }
    }
}

// MARK: - Collage Creator
struct CollageCreatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var photos: [SharedPhoto]
    
    @State private var selectedPhotos: Set<SharedPhoto> = []
    @State private var collageTitle = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Название коллажа", text: $collageTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                if photos.isEmpty {
                    Spacer()
                    Text("Сначала добавьте фотографии в альбом")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 6),
                            GridItem(.flexible(), spacing: 6),
                            GridItem(.flexible(), spacing: 6)
                        ], spacing: 6) {
                            ForEach(photos) { photo in
                                if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 100)
                                        .clipped()
                                        .overlay(alignment: .topTrailing) {
                                            if selectedPhotos.contains(photo) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(.pink)
                                                    .background(Circle().fill(.white))
                                                    .padding(4)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .onTapGesture {
                                            if selectedPhotos.contains(photo) {
                                                selectedPhotos.remove(photo)
                                            } else {
                                                selectedPhotos.insert(photo)
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Создать коллаж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        let collage = Collage(title: collageTitle.isEmpty ? "Коллаж" : collageTitle)
                        modelContext.insert(collage)
                        dismiss()
                    }
                    .disabled(selectedPhotos.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AlbumView()
        .modelContainer(for: [SharedPhoto.self, Collage.self], inMemory: true)
}
