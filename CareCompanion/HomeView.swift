
import SwiftUI

struct HomeView: View {

    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var locationManager = CareLocationManager.shared

    private let teal = Color(
        red: 0.05,
        green: 0.58,
        blue: 0.53
    )

    private let background = Color(
        red: 0.96,
        green: 0.98,
        blue: 0.97
    )

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {

                headerSection

                welcomeSection

                languageSection

                locationSection

                featuresSection

                communitySection

                footerSection
            }
            .padding(20)
            .padding(.bottom, 30)
        }
        .background(background.ignoresSafeArea())
        .navigationTitle("Care Companion")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {

            Image("CareCompanionLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text("Care Companion")
                    .font(.title2.bold())

                Text("Your care. Anywhere.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.top, 12)
    }

    // MARK: - Welcome

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Welcome to\nCare Companion")
                .font(.system(size: 32, weight: .bold))

            Text("Your care. Your language. Your community.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Language

    private var languageSection: some View {
        HStack(spacing: 12) {

            Image(systemName: "globe")
                .font(.title2)
                .foregroundStyle(teal)

            Text("App Language")
                .font(.headline)

            Spacer()

            Picker(
                "Language",
                selection: $languageManager.language
            ) {
                ForEach(
                    languageManager.languages,
                    id: \.code
                ) { item in
                    Text(item.name)
                        .tag(item.code)
                }
            }
            .tint(teal)
        }
        .padding(18)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Saved Location

    private var locationSection: some View {
        NavigationLink {
            ProfileView()
        } label: {

            HStack(spacing: 14) {

                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(teal)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {

                    Text("Your saved location")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        locationManager.hasLocation
                        ? locationManager.locationText
                        : "Set your location"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Main Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Your Care Companion")
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 14) {

                NavigationLink {
                    CareAIView()
                } label: {
                    featureCard(
                        title: "AI Assistant",
                        subtitle: "Ask for guidance",
                        icon: "sparkles",
                        color: .purple
                    )
                }

                NavigationLink {
                    CareMapView(initialQuery: "Hospital")
                } label: {
                    featureCard(
                        title: "Find Healthcare",
                        subtitle: "Hospitals & clinics",
                        icon: "cross.case.fill",
                        color: .cyan
                    )
                }

                NavigationLink {
                    EmergencyView()
                } label: {
                    featureCard(
                        title: "Emergency Help",
                        subtitle: "Find support",
                        icon: "cross.circle.fill",
                        color: .red
                    )
                }

                NavigationLink {
                    CommunityExploreView()
                } label: {
                    featureCard(
                        title: "Education & Family",
                        subtitle: "Schools, parks & more",
                        icon: "graduationcap.fill",
                        color: .blue
                    )
                }

                NavigationLink {
                    MyRecordsView()
                } label: {
                    featureCard(
                        title: "My Records",
                        subtitle: "Personal documents",
                        icon: "folder.fill",
                        color: .orange
                    )
                }

                NavigationLink {
                    ProfileView()
                } label: {
                    featureCard(
                        title: "My Profile",
                        subtitle: "Account & preferences",
                        icon: "person.crop.circle.fill",
                        color: .teal
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Feature Card

    private func featureCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            Image(systemName: icon)
                .font(.system(size: 27))
                .foregroundStyle(color)
                .frame(width: 54, height: 54)
                .background(color.opacity(0.12))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )

            Spacer(minLength: 8)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - Community Resources

    private var communitySection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Explore Community Resources")
                .font(.title2.bold())

            resourceLink(
                title: "Emergency Shelters",
                subtitle: "Find nearby shelter listings",
                icon: "house.fill",
                query: "Emergency shelter"
            )

            resourceLink(
                title: "Food Assistance",
                subtitle: "Food banks and community support",
                icon: "fork.knife",
                query: "Food bank"
            )

            resourceLink(
                title: "Pharmacies",
                subtitle: "Find nearby pharmacies",
                icon: "pills.fill",
                query: "Pharmacy"
            )

            resourceLink(
                title: "Mental Health Support",
                subtitle: "Find mental health services",
                icon: "brain.head.profile",
                query: "Mental health clinic"
            )

            resourceLink(
                title: "Senior Care",
                subtitle: "Support for older adults",
                icon: "figure.walk",
                query: "Senior center"
            )

            resourceLink(
                title: "Maternal Healthcare",
                subtitle: "Pregnancy and family care",
                icon: "heart.fill",
                query: "Maternity clinic"
            )

            NavigationLink {
                CommunityExploreView()
            } label: {
                resourceRow(
                    title: "Schools & Playgrounds",
                    subtitle: "Explore education and recreation",
                    icon: "book.fill"
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Resource Link

    private func resourceLink(
        title: String,
        subtitle: String,
        icon: String,
        query: String
    ) -> some View {

        NavigationLink {
            CareMapView(initialQuery: query)
        } label: {
            resourceRow(
                title: title,
                subtitle: subtitle,
                icon: icon
            )
        }
        .buttonStyle(.plain)
    }

    private func resourceRow(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(teal)
                .frame(width: 44, height: 44)
                .background(teal.opacity(0.1))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

            VStack(alignment: .leading, spacing: 5) {

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
        .padding(16)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 10) {

            Image("CareCompanionLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 95, height: 95)

            Text("Care Companion")
                .font(.headline)
                .foregroundStyle(teal)

            Text("Your Language. Your Health. Your Community.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(
                "Care Companion provides informational resources. " +
                "For life-threatening emergencies, contact local emergency services."
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
