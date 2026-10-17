
import SwiftUI

struct SmartLocationView: View {

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Image(systemName: "location.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.teal)

                Text("Smart Location")
                    .font(.largeTitle.bold())

                Text(
                    "Care Companion uses the city, state, and country saved in your account. It does not track your live GPS location."
                )
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 14) {

                    detail("City", value: locationManager.city)
                    detail("State", value: locationManager.state)
                    detail("Country", value: locationManager.country)

                }
                .padding()
                .background(
                    Color(.secondarySystemGroupedBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if locationManager.isLoading {
                    ProgressView("Loading profile...")
                }

                if let error = locationManager.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    Task {
                        await locationManager.loadProfile()
                    }
                } label: {
                    Label(
                        "Refresh Saved Location",
                        systemImage: "arrow.clockwise"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .disabled(locationManager.isLoading)

                NavigationLink {
                    ProfileView()
                } label: {
                    Label(
                        "Open My Profile",
                        systemImage: "person.crop.circle"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if locationManager.hasLocation {
                    NavigationLink {
                        CareMapView(
                            initialQuery: "Hospital",
                            initialLocation: locationManager.locationText
                        )
                    } label: {
                        Label(
                            "Test Hospital Search",
                            systemImage: "map.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.teal)
                }

                Text(
                    "If you change your location in Profile, return here and tap Refresh Saved Location."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Smart Location")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await locationManager.loadProfile()
        }
    }

    private func detail(
        _ title: String,
        value: String
    ) -> some View {

        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value.isEmpty ? "Not set" : value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationStack {
        SmartLocationView()
    }
}
