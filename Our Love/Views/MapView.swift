//  MapView.swift
//  Our Love

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct MapView: View {
    @Query private var places: [Place]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddPlace = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedPlace: Place?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Map
                Map(initialPosition: .region(region)) {
                    ForEach(places) { place in
                        Annotation(place.title, coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )) {
                            Button {
                                selectedPlace = place
                            } label: {
                                Text(place.emoji)
                                    .font(.title2)
                                    .padding(6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                
                // Add button
                Button {
                    showingAddPlace = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: .pink.opacity(0.3), radius: 10)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                
                // Places list overlay
                if !places.isEmpty {
                    VStack {
                        Spacer()
                        placesPreview
                    }
                }
            }
            .navigationTitle("Наша карта")
            .sheet(isPresented: $showingAddPlace) {
                AddPlaceView()
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
        }
    }
    
    // MARK: - Places Preview
    private var placesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(places) { place in
                    Button {
                        selectedPlace = place
                        withAnimation {
                            region.center = CLLocationCoordinate2D(
                                latitude: place.latitude,
                                longitude: place.longitude
                            )
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(place.emoji)
                                .font(.title)
                            Text(place.title)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    .frame(width: 90)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Add Place View
struct AddPlaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var emoji = "❤️"
    @State private var latitude: Double = 55.751244
    @State private var longitude: Double = 37.618423
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    let emojis = ["❤️", "💋", "🌅", "☕️", "🍝", "🏖", "🏔", "🏛", "🎬", "🌳", "🏠", "✈️", "🎡", "⛪️"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Место") {
                    TextField("Название места", text: $title)
                    TextField("Описание", text: $description)
                }
                
                Section("Эмодзи") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(emojis, id: \.self) { emojiItem in
                            Text(emojiItem)
                                .font(.title2)
                                .padding(8)
                                .background(emoji == emojiItem ? Color.pink.opacity(0.2) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    emoji = emojiItem
                                }
                        }
                    }
                }
                
                Section("Поиск места") {
                    TextField("Поиск на карте...", text: $searchText)
                        .onSubmit {
                            searchLocation()
                        }
                    
                    ForEach(searchResults, id: \.self) { result in
                        Button {
                            if let location = result.placemark.location {
                                latitude = location.coordinate.latitude
                                longitude = location.coordinate.longitude
                                if title.isEmpty {
                                    title = result.name ?? ""
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.name ?? "")
                                    .font(.subheadline)
                                Text(result.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Координаты") {
                    HStack {
                        Text("Широта:")
                        TextField("", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Долгота:")
                        TextField("", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Новое место")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        savePlace()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        Task {
            let search = MKLocalSearch(request: request)
            if let response = try? await search.start() {
                searchResults = response.mapItems
            }
        }
    }
    
    private func savePlace() {
        let place = Place(
            title: title,
            placeDescription: description,
            emoji: emoji,
            latitude: latitude,
            longitude: longitude
        )
        modelContext.insert(place)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Place Detail
struct PlaceDetailView: View {
    @Bindable var place: Place
    @State private var region: MKCoordinateRegion
    
    init(place: Place) {
        self.place = place
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Map preview
                    Map(initialPosition: .region(region)) {
                        Annotation(place.title, coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude, longitude: place.longitude
                        )) {
                            Text(place.emoji)
                                .font(.title)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    // Info
                    VStack(spacing: 12) {
                        HStack {
                            Text(place.emoji)
                                .font(.system(size: 48))
                            VStack(alignment: .leading) {
                                Text(place.title)
                                    .font(.title2.weight(.bold))
                                Text(place.placeDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Добавлено \(place.createdAt, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Детали")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapView()
        .modelContainer(for: [Place.self], inMemory: true)
}
