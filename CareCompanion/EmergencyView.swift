
import SwiftUI

struct EmergencyView: View {

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    @State private var city = ""

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                Label(
                    "Emergency Assistance",
                    systemImage: "cross.circle.fill"
                )
                .font(.title.bold())
                .foregroundStyle(.red)

                Text(
                    "Find shelter listings, prepare for disasters, and access official emergency resources."
                )
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {

                    Text("Find a Shelter")
                        .font(.title3.bold())

                    TextField(
                        "City, State or Country",
                        text: $city
                    )
                    .textFieldStyle(.roundedBorder)

                    NavigationLink {

                        CareMapView(
                            initialQuery: "Emergency shelter",
                            initialLocation: city
                        )

                    } label: {

                        Label(
                            "Search Shelter Listings",
                            systemImage: "map.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)

                    Text(
                        "Map results are not verified active disaster shelters. Confirm availability with local authorities."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    Color(.secondarySystemGroupedBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("Emergency Safety")
                    .font(.title3.bold())

                safetyCard(
                    "Tornado",
                    icon: "tornado",
                    advice: "Go to a basement or small interior room on the lowest floor, away from windows."
                )

                safetyCard(
                    "Hurricane",
                    icon: "hurricane",
                    advice: "Follow official evacuation orders. Prepare medications, water, documents and emergency supplies."
                )

                safetyCard(
                    "Flood",
                    icon: "water.waves",
                    advice: "Move to higher ground. Never walk or drive through floodwater."
                )

                safetyCard(
                    "Earthquake",
                    icon: "waveform.path",
                    advice: "Drop, cover and hold on. Stay away from windows and falling objects."
                )

                Text("Official Resources")
                    .font(.title3.bold())

                officialLink(
                    "American Red Cross Shelters",
                    url: "https://www.redcross.org/get-help/disaster-relief-and-recovery-services/find-an-open-shelter.html"
                )

                officialLink(
                    "Ready.gov Disaster Preparedness",
                    url: "https://www.ready.gov/"
                )

                officialLink(
                    "Global Humanitarian Updates",
                    url: "https://reliefweb.int/"
                )

                Text(
                    "In immediate danger, contact your country's emergency services. Emergency numbers vary by location."
                )
                .font(.footnote.bold())
                .foregroundStyle(.red)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Emergency Help")
        .navigationBarTitleDisplayMode(.inline)
        .task {

            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }

            if city.isEmpty {
                city = locationManager.locationText
            }
        }
    }

    private func safetyCard(
        _ title: String,
        icon: String,
        advice: String
    ) -> some View {

        HStack(alignment: .top, spacing: 14) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.red)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 5) {

                Text(title)
                    .font(.headline)

                Text(advice)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func officialLink(
        _ title: String,
        url: String
    ) -> some View {

        Link(destination: URL(string: url)!) {

            HStack {

                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.teal)

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .foregroundStyle(.teal)
            }
            .padding()
            .background(
                Color(.secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    NavigationStack {
        EmergencyView()
    }
}
