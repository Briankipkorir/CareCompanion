
import Foundation
import Combine
import Supabase

@MainActor
final class AuthManager: ObservableObject {

    static let shared = AuthManager()

    @Published var isSignedIn = false
    @Published var isLoading = true
    @Published var needsPasswordReset = false

    private let client = SupabaseManager.client

    static let redirectURL = URL(
        string: "carecompanion://auth-callback"
    )!

    private init() {
        Task {
            await observeAuthentication()
        }
    }

    private func observeAuthentication() async {
        isSignedIn = client.auth.currentSession != nil
        isLoading = false

        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .passwordRecovery:
                needsPasswordReset = true
                isSignedIn = true

            case .signedOut:
                isSignedIn = false
                needsPasswordReset = false

            default:
                isSignedIn = session != nil
            }

            isLoading = false
        }
    }

    func signUp(
        email: String,
        password: String
    ) async throws -> Bool {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            redirectTo: Self.redirectURL
        )

        return response.session != nil
    }

    func signIn(
        email: String,
        password: String
    ) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )

        isSignedIn = true
    }

    func resendConfirmation(email: String) async throws {
        try await client.auth.resend(
            email: email,
            type: .signup,
            emailRedirectTo: Self.redirectURL
        )
    }

    func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(
            email,
            redirectTo: Self.redirectURL
        )
    }

    func updatePassword(_ password: String) async throws {
        try await client.auth.update(
            user: UserAttributes(password: password)
        )

        needsPasswordReset = false
    }

    func signOut() async throws {
        try await client.auth.signOut()
        isSignedIn = false
        needsPasswordReset = false
    }

    func handleDeepLink(_ url: URL) {
        client.auth.handle(url)
    }
}
