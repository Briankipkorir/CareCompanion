import SwiftUI

@main
struct CareCompanionApp: App {

    @StateObject private var auth = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoading {
                    ProgressView("Loading Care Companion...")
                } else if auth.needsPasswordReset {
                    ResetPasswordView()
                } else if auth.isSignedIn {
                    NavigationStack {
                        HomeView()
                    }
                } else {
                    ContentView()
                }
            }
            .onOpenURL { url in
                auth.handleDeepLink(url)
            }
        }
    }
}
