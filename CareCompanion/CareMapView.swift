
import SwiftUI
import MapKit

struct CarePlace: Identifiable {

    let id = UUID()
    let item: MKMapItem

    var name: String {
        item.name ?? "Unknown place"
    }

    var address: String {
        item.placemark.title ?? "Address unavailable"
    }

    var coordinate: CLLocationCoordinate2D {
        item.placemark.coordinate
    }

    var phoneNumber: String? {
        item.phoneNumber
    }

    var website: URL? {
        item.url
    }

    var phoneURL: URL? {

        guard let phoneNumber else {
            return nil
        }

        let allowed = CharacterSet(
            charactersIn: "+0123456789"
        )

        let cleaned = String(
            phoneNumber.unicodeScalars.filter {
                allowed.contains($0)
            }
        )

        guard !cleaned.isEmpty else {
            return nil
        }

        return URL(string: "tel:\(cleaned)")
    }
}

struct CareMapView: View {

    let initialQuery: String
    let initialLocation: String

    @Environment(\.openURL)
    private var openURL

    @ObservedObject private var languageManager =
        LanguageManager.shared

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    @State private var searchText: String
    @State private var locationText: String

    @State private var places: [CarePlace] = []

    @State private var cameraPosition: MapCameraPosition =
        .automatic

    @State private var isSearching = false
    @State private var errorMessage: String?

    init(
        initialQuery: String = "",
        initialLocation: String = ""
    ) {

        self.initialQuery = initialQuery
        self.initialLocation = initialLocation

        _searchText = State(initialValue: initialQuery)
        _locationText = State(initialValue: initialLocation)
    }

    var body: some View {

        VStack(spacing: 12) {

            searchSection

            Map(position: $cameraPosition) {

                ForEach(places) { place in

                    Marker(
                        place.name,
                        coordinate: place.coordinate
                    )
                    .tint(.teal)
                }
            }
            .frame(height: 270)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .padding(.horizontal)

            if isSearching {
                ProgressView("Searching for places...")
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            if places.isEmpty && !isSearching {

                Button {
                    openAppleMapsSearch()
                } label: {
                    Label(
                        languageManager.text("openMaps"),
                        systemImage: "map"
                    )
                }
                .buttonStyle(.bordered)
                .tint(.teal)
            }

            if !places.isEmpty {

                HStack {

                    Text("\(places.count) locations found")
                        .font(.subheadline.bold())

                    Spacer()
                }
                .padding(.horizontal)
            }

            List(places) { place in
                placeCard(place)
            }
            .listStyle(.plain)
        }
        .navigationTitle(languageManager.text("map"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await prepareLocation()
        }
    }

    // MARK: - Default Location

    @MainActor
    private func prepareLocation() async {

        if locationManager.hasLocation == false {
            await locationManager.loadProfile()
        }

        // An explicitly requested location always wins.
        if initialLocation.isEmpty {

            locationText = locationManager.locationText

        } else {

            locationText = initialLocation
        }

        if !searchText.isEmpty &&
            !locationText.isEmpty {

            await searchPlaces()
        }
    }

    // MARK: - Search Fields

    private var searchSection: some View {

        VStack(spacing: 10) {

            TextField(
                "City, State or Country",
                text: $locationText
            )
            .textFieldStyle(.roundedBorder)

            HStack {

                TextField(
                    "Search for services",
                    text: $searchText
                )
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await searchPlaces()
                    }
                }

                Button {
                    Task {
                        await searchPlaces()
                    }
                } label: {

                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
                .disabled(isSearching)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Place Card

    private func placeCard(
        _ place: CarePlace
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(place.name)
                .font(.headline)

            Text(place.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let phone = place.phoneNumber,
               !phone.isEmpty {

                Label(
                    phone,
                    systemImage: "phone"
                )
                .font(.subheadline)

            } else {

                Text("Phone number unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Label(
                "Hours not verified — check with the location",
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 10) {

                if let phoneURL = place.phoneURL {

                    Link(destination: phoneURL) {

                        Label(
                            "Call",
                            systemImage: "phone.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }

                Button {
                    showDirections(to: place)
                } label: {

                    Label(
                        languageManager.text("directions"),
                        systemImage:
                            "arrow.triangle.turn.up.right.diamond"
                    )
                }
                .buttonStyle(.bordered)
                .tint(.teal)
            }

            HStack(spacing: 10) {

                if let website = place.website {

                    Link(destination: website) {

                        Label(
                            "Website",
                            systemImage: "globe"
                        )
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    place.item.openInMaps()
                } label: {

                    Label(
                        "Check Details & Hours",
                        systemImage: "clock.fill"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Search

    @MainActor
    private func searchPlaces() async {

        let service = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let location = locationText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !service.isEmpty else {
            errorMessage = "Enter a service to search."
            return
        }

        guard !location.isEmpty else {
            errorMessage = "Enter a city or country."
            return
        }

        isSearching = true
        errorMessage = nil
        places = []

        defer {
            isSearching = false
        }

        do {

            let locationRequest = MKLocalSearch.Request()

            locationRequest.naturalLanguageQuery =
                location

            let locationResponse = try await MKLocalSearch(
                request: locationRequest
            ).start()

            guard let city = locationResponse.mapItems.first else {
                errorMessage = "Location not found."
                return
            }

            let region = MKCoordinateRegion(
                center: city.placemark.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.25,
                    longitudeDelta: 0.25
                )
            )

            cameraPosition = .region(region)

            let serviceRequest = MKLocalSearch.Request()

            serviceRequest.naturalLanguageQuery =
                service

            serviceRequest.region = region

            let response = try await MKLocalSearch(
                request: serviceRequest
            ).start()

            places = response.mapItems.map {
                CarePlace(item: $0)
            }

            if places.isEmpty {

                errorMessage =
                    languageManager.text("noResults")

            } else {

                cameraPosition = .region(
                    response.boundingRegion
                )
            }

        } catch {

            print("Map search error:", error)

            errorMessage =
                languageManager.text("searchFailed")
        }
    }

    // MARK: - Directions

    private func showDirections(
        to place: CarePlace
    ) {

        place.item.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    // MARK: - Apple Maps Fallback

    private func openAppleMapsSearch() {

        let query = "\(searchText) \(locationText)"

        var components = URLComponents(
            string: "https://maps.apple.com/"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "q",
                value: query
            )
        ]

        if let url = components?.url {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        CareMapView(
            initialQuery: "Hospital",
            initialLocation: "Nairobi, Kenya"
        )
    }
}
