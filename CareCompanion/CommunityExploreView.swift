
import SwiftUI

struct CommunityExploreView: View {

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    private let teal = Color.teal

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                header

                sectionTitle("Education", icon: "graduationcap.fill")

                placeLink(
                    "Schools",
                    subtitle: "Elementary and secondary schools",
                    icon: "building.2.fill",
                    query: "School"
                )

                placeLink(
                    "Colleges & Universities",
                    subtitle: "Higher education institutions",
                    icon: "graduationcap.fill",
                    query: "University college"
                )

                placeLink(
                    "Libraries",
                    subtitle: "Books, learning and study spaces",
                    icon: "books.vertical.fill",
                    query: "Public library"
                )

                placeLink(
                    "Tutoring & Learning",
                    subtitle: "Educational support centers",
                    icon: "book.fill",
                    query: "Tutoring center"
                )

                sectionTitle(
                    "Family & Recreation",
                    icon: "figure.2.and.child.holdinghands"
                )

                placeLink(
                    "Playgrounds",
                    subtitle: "Find playgrounds in your community",
                    icon: "figure.play",
                    query: "Playground"
                )

                placeLink(
                    "Public Parks",
                    subtitle: "Outdoor family recreation",
                    icon: "tree.fill",
                    query: "Public park"
                )

                placeLink(
                    "Recreation Centers",
                    subtitle: "Sports and community activities",
                    icon: "figure.run",
                    query: "Recreation center"
                )

                placeLink(
                    "Community Centers",
                    subtitle: "Local programs and family support",
                    icon: "person.3.fill",
                    query: "Community center"
                )

                Text(
                    "Place listings do not guarantee safety, supervision, accessibility, or current opening hours. Check local conditions before visiting."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Explore Community")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }
        }
    }

    private var header: some View {

        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: "globe.americas.fill")
                .font(.system(size: 36))
                .foregroundStyle(teal)

            Text("Discover Your Community")
                .font(.title.bold())

            Text(
                "Explore education, recreation, and family resources around the world."
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
    }

    private func sectionTitle(
        _ title: String,
        icon: String
    ) -> some View {

        Label(title, systemImage: icon)
            .font(.title3.bold())
            .padding(.top, 8)
    }

    private func placeLink(
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

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

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
        CommunityExploreView()
    }
}
