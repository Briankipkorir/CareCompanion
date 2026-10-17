
import Foundation
import Combine
import Supabase

// MARK: - Profile Location Data

struct CareProfileLocation: Decodable {

    let city: String?
    let state: String?
    let country: String?
    let preferredLanguage: String?

    enum CodingKeys: String, CodingKey {
        case city
        case state
        case country
        case preferredLanguage = "preferred_language"
    }
}

// MARK: - Location Manager

@MainActor
final class CareLocationManager: ObservableObject {

    static let shared = CareLocationManager()

    @Published private(set) var city = ""
    @Published private(set) var state = ""
    @Published private(set) var country = ""

    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private init() {}

    var locationText: String {

        [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var hasLocation: Bool {
        !locationText.isEmpty
    }

    // Load the signed-in user's saved location.

    func loadProfile() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            let user = try await
                SupabaseManager.client.auth.user()

            let profile: CareProfileLocation =
                try await SupabaseManager.client
                    .from("profiles")
                    .select(
                        "city, state, country, preferred_language"
                    )
                    .eq("id", value: user.id.uuidString)
                    .single()
                    .execute()
                    .value

            city = profile.city ?? ""
            state = profile.state ?? ""
            country = profile.country ?? ""

        } catch {

            print("Profile location error:", error)

            errorMessage =
                "Could not load your saved location."
        }
    }

    // Clear user-specific data when signing out.

    func clear() {
        city = ""
        state = ""
        country = ""
        errorMessage = nil
    }
}
