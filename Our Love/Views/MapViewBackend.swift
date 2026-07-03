import SwiftUI
import MapKit

// MARK: - Map View Backend

struct MapViewBackend: View {
    @EnvironmentObject var viewModel: MapViewModel
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
                    ForEach(viewModel.places) { place in
                        Annotation(place.title, coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )) {
                            Button {
                                selectedPlace = place
                            } label: {
                                Image(systemName: place.emoji)
                                    .font(.title2)
                                    .foregroundStyle(.pink)
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
                if !viewModel.places.isEmpty {
                    VStack {
                        Spacer()
                        placesPreview
                    }
                }
            }
            .navigationTitle("Наша карта")
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showingAddPlace) {
                AddPlaceViewBackend()
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailViewBackend(place: place)
            }
        }
    }
    
    // MARK: - Places Preview
    private var placesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.places) { place in
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
                            Image(systemName: place.emoji)
                                .font(.title)
                                .foregroundStyle(.pink)
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

// MARK: - Add Place View Backend

struct AddPlaceViewBackend: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MapViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var emoji = "heart.fill"
    @State private var latitude: Double = 55.751244
    @State private var longitude: Double = 37.618423
    
    let placeIcons = ["heart.fill", "heart.circle", "sun.horizon.fill", "cup.and.saucer.fill", "fork.knife", "beach.umbrella.fill", "mountain.2.fill", "building.columns.fill", "film.fill", "leaf.fill", "house.fill", "airplane", "ferriswheel", "building.2.fill"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Место") {
                    TextField("Название места", text: $title)
                    TextField("Описание", text: $description)
                }
                
                Section("Иконка") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(placeIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(.pink)
                                .padding(8)
                                .background(emoji == icon ? Color.pink.opacity(0.2) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    emoji = icon
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
    
    private func savePlace() {
        Task {
            await viewModel.addPlace(
                title: title,
                description: description,
                emoji: emoji,
                latitude: latitude,
                longitude: longitude
            )
            dismiss()
        }
    }
}

// MARK: - Place Detail View Backend

struct PlaceDetailViewBackend: View {
    let place: Place
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
                            Image(systemName: place.emoji)
                                .font(.title)
                                .foregroundStyle(.pink)
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
                            Image(systemName: place.emoji)
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                            VStack(alignment: .leading) {
                                Text(place.title)
                                    .font(.title2.weight(.bold))
                                Text(place.description)
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
    MapViewBackend()
        .environmentObject(MapViewModel(placeUseCase: DIContainer.shared.placeUseCase))
}
