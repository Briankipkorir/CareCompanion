
import SwiftUI
import Supabase

// MARK: - User Profile Model

struct UserProfile: Codable {
    let id: UUID
    var full_name: String?
    var preferred_language: String
    var country: String?
    var city: String?
    var state: String?
}

// MARK: - Profile Screen

struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var preferredLanguage = "English"
    @State private var country = ""
    @State private var city = ""
    @State private var state = ""

    @State private var isLoading = true
    @State private var isSaving = false
    @State private var isSigningOut = false

    @State private var message = ""
    @State private var showMessage = false
    @State private var showLogoutConfirmation = false

    private let teal = Color(
        red: 0.05,
        green: 0.58,
        blue: 0.53
    )

    private let languages = [
        "English",
        "Spanish",
        "French",
        "Swahili",
        "Arabic",
        "Chinese",
        "Hindi",
        "Portuguese",
        "German",
        "Somali",
        "Amharic",
        "Other"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 85))
                    .foregroundStyle(teal)
                    .padding(.top, 30)

                Text("My Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your information, your language, your community.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if isLoading {

                    ProgressView("Loading profile...")
                        .padding()

                } else {

                    VStack(alignment: .leading, spacing: 20) {

                        profileField(
                            "Full Name",
                            placeholder: "Enter your full name",
                            value: $fullName
                        )

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Preferred Language")
                                .font(.headline)

                            Picker(
                                "Language",
                                selection: $preferredLanguage
                            ) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language).tag(language)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(teal)
                        }

                        profileField(
                            "Country",
                            placeholder: "Enter your country",
                            value: $country
                        )

                        profileField(
                            "City / Town",
                            placeholder: "Enter your city",
                            value: $city
                        )

                        profileField(
                            "State / Province / County / Region",
                            placeholder: "Optional",
                            value: $state
                        )

                        Text(
                            "For example: Tennessee, Ontario, or Nairobi County."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        // MARK: Save Profile

                        Button {
                            Task {
                                await saveProfile()
                            }
                        } label: {

                            HStack(spacing: 10) {

                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(
                                        systemName: "checkmark.circle.fill"
                                    )
                                }

                                Text(
                                    isSaving
                                    ? "Saving..."
                                    : "Save Profile"
                                )
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(teal)
                            .foregroundStyle(.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                        .disabled(isSaving || isSigningOut)

                        Divider()
                            .padding(.vertical, 8)

                        // MARK: Log Out

                        Button {
                            showLogoutConfirmation = true
                        } label: {

                            HStack(spacing: 10) {

                                if isSigningOut {
                                    ProgressView()
                                        .tint(.red)
                                } else {
                                    Image(
                                        systemName: "rectangle.portrait.and.arrow.right"
                                    )
                                }

                                Text(
                                    isSigningOut
                                    ? "Logging Out..."
                                    : "Log Out"
                                )
                            }
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.08))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                        .disabled(isSigningOut || isSaving)

                        Text(
                            "Logging out ends your current Care Companion session."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(22)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .shadow(
                        color: .black.opacity(0.06),
                        radius: 10
                    )
                }
            }
            .padding(20)
        }
        .background(
            Color(
                red: 0.96,
                green: 0.98,
                blue: 0.97
            )
        )
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProfile()
        }
        .alert(
            "Care Companion",
            isPresented: $showMessage
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
        .confirmationDialog(
            "Are you sure you want to log out?",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {

            Button("Log Out", role: .destructive) {
                Task {
                    await logout()
                }
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Reusable Profile Field

    private func profileField(
        _ title: String,
        placeholder: String,
        value: Binding<String>
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.headline)

            TextField(
                placeholder,
                text: value
            )
            .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Load Profile

    private func loadProfile() async {

        isLoading = true
        defer { isLoading = false }

        do {

            let user = try await SupabaseManager.client.auth.user()

            let profiles: [UserProfile] = try await SupabaseManager.client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .execute()
                .value

            if let profile = profiles.first {

                fullName = profile.full_name ?? ""

                preferredLanguage = languages.contains(
                    profile.preferred_language
                )
                ? profile.preferred_language
                : "Other"

                country = profile.country ?? ""
                city = profile.city ?? ""
                state = profile.state ?? ""
            }

        } catch {

            message = "Unable to load profile: \(error.localizedDescription)"
            showMessage = true
        }
    }

    // MARK: - Save Profile

    private func saveProfile() async {

        isSaving = true
        defer { isSaving = false }

        do {

            let user = try await SupabaseManager.client.auth.user()

            let profile = UserProfile(
                id: user.id,
                full_name: fullName,
                preferred_language: preferredLanguage,
                country: country,
                city: city,
                state: state
            )

            try await SupabaseManager.client
                .from("profiles")
                .upsert(profile)
                .execute()

            await CareLocationManager.shared.loadProfile()

            message = "Your profile has been saved successfully!"
            showMessage = true

        } catch {

            message = "Unable to save profile: \(error.localizedDescription)"
            showMessage = true
        }
    }

    // MARK: - Log Out

    private func logout() async {

        isSigningOut = true
        defer { isSigningOut = false }

        do {

            try await SupabaseManager.client.auth.signOut()

            CareLocationManager.shared.clear()

            // Dismiss this screen.
            // The app's root authentication observer should
            // switch from HomeView to LoginView.
            dismiss()

        } catch {

            message = "Unable to log out: \(error.localizedDescription)"
            showMessage = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
}
