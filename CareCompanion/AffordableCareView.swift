
import SwiftUI

struct AffordableCareView: View {

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    private let teal = Color.teal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(teal)

                    Text("No Insurance? Find Care")
                        .font(.title.bold())

                    Text(
                        "Find affordable healthcare, community clinics, and hospitals that may offer financial assistance."
                    )
                    .foregroundStyle(.secondary)

                    if locationManager.hasLocation {
                        Label(
                            locationManager.locationText,
                            systemImage: "location.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(teal)
                    }
                }

                Text("Find Affordable Care")
                    .font(.title3.bold())

                careLink(
                    "Community Health Centers",
                    subtitle: "Ask about income-based fees",
                    icon: "cross.case.fill",
                    query: "Federally qualified health center"
                )

                careLink(
                    "Free Medical Clinics",
                    subtitle: "Search for charitable clinics",
                    icon: "heart.fill",
                    query: "Free medical clinic"
                )

                careLink(
                    "Low-Cost Clinics",
                    subtitle: "Find sliding-scale healthcare",
                    icon: "stethoscope",
                    query: "Sliding scale medical clinic"
                )

                careLink(
                    "Hospitals with Financial Assistance",
                    subtitle: "Ask about charity care",
                    icon: "building.2.fill",
                    query: "Nonprofit hospital"
                )

                careLink(
                    "Emergency Departments",
                    subtitle: "For medical emergencies",
                    icon: "cross.circle.fill",
                    query: "Hospital emergency department"
                )

                Divider()

                Text("Official U.S. Resources")
                    .font(.title3.bold())

                Link(
                    destination: URL(
                        string: "https://findahealthcenter.hrsa.gov/"
                    )!
                ) {
                    Label(
                        "Find a Health Center — HRSA",
                        systemImage: "arrow.up.right.square"
                    )
                }

                Text(
                    "Community health centers can provide discounted care based on income. Search results do not guarantee a facility is free or accepts new patients."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Text(
                    "If you have a medical emergency, contact local emergency services or go to an emergency department. Emergency treatment may still result in a bill."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Affordable Care")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }
        }
    }

    private func careLink(
        _ title: String,
        subtitle: String,
        icon: String,
        query: String
    ) -> some View {

        NavigationLink {
            CareMapView(initialQuery: query)
        } label: {

            HStack(spacing: 14) {

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(teal)
                    .frame(width: 46, height: 46)
                    .background(teal.opacity(0.12))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                Color(.secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AffordableCareView()
    }
}
