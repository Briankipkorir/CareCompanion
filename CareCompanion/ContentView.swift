
import SwiftUI

struct ContentView: View {

    private let teal = Color(
        red: 0.05,
        green: 0.58,
        blue: 0.53
    )

    private let backgroundColor = Color(
        red: 0.96,
        green: 0.98,
        blue: 0.97
    )

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {

                        Spacer(minLength: 50)

                        // Official Care Companion logo
                        Image("CareCompanionLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(
                                    geometry.size.width - 48,
                                    340
                                )
                            )
                            .accessibilityLabel(
                                "Care Companion official logo"
                            )

                        // Welcome message
                        Text("Welcome to Care Companion")
                            .font(.system(
                                size: 28,
                                weight: .bold
                            ))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 15)

                        // App tagline
                        Text(
                            "Your Language. Your Health.\nYour Community."
                        )
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 70)

                        // Buttons
                        VStack(spacing: 18) {

                            // Create account
                            NavigationLink {
                                SignUpView()
                            } label: {
                                HStack(spacing: 10) {
                                    Text("Get Started")

                                    Image(
                                        systemName: "arrow.right"
                                    )
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(18)
                                .background(teal)
                                .foregroundStyle(.white)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                            }

                            // Existing account login
                            NavigationLink {
                                LoginView()
                            } label: {
                                Text(
                                    "I Already Have an Account"
                                )
                                .font(.headline)
                                .foregroundStyle(teal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Footer
                        Text(
                            "Connecting people to care, resources, and community."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 12)

                        Spacer(minLength: 35)
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: geometry.size.height
                    )
                }
                .background(
                    backgroundColor.ignoresSafeArea()
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
