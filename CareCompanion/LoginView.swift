
import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var message = ""
    @State private var showAlert = false

    private let teal = Color(
        red: 0.05,
        green: 0.58,
        blue: 0.53
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                headerSection

                VStack(spacing: 20) {
                    emailSection
                    passwordSection
                    forgotPasswordLink
                    signInButton
                }
                .padding(22)
                .background(
                    Color(.secondarySystemGroupedBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 22)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 12,
                    y: 5
                )

                createAccountLink

                Text("Your Care. Your Language. Your Community.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
            .padding(24)
        }
        .background(
            Color(
                red: 0.96,
                green: 0.98,
                blue: 0.97
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Care Companion",
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
    }

    // MARK: - Logo and Welcome

    private var headerSection: some View {
        VStack(spacing: 12) {

            Image("CareCompanionLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 270)
                .frame(height: 210)
                .accessibilityLabel("Care Companion logo")
                .padding(.top, 15)

            Text("Welcome Back")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("Sign in to continue with Care Companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Email

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Email Address")
                .font(.headline)

            TextField(
                "Enter your email",
                text: $email
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .submitLabel(.next)
        }
    }

    // MARK: - Password

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Password")
                .font(.headline)

            HStack(spacing: 12) {

                Group {
                    if showPassword {
                        TextField(
                            "Enter your password",
                            text: $password
                        )
                    } else {
                        SecureField(
                            "Enter your password",
                            text: $password
                        )
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit {
                    Task {
                        await logIn()
                    }
                }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(
                        systemName: showPassword
                            ? "eye.slash"
                            : "eye"
                    )
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    showPassword
                        ? "Hide password"
                        : "Show password"
                )
            }
            .padding(12)
            .background(
                Color(.systemBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.gray.opacity(0.25)
                    )
            }
        }
    }

    // MARK: - Forgot Password

    private var forgotPasswordLink: some View {
        HStack {

            Spacer()

            NavigationLink {
                ForgotPasswordView()
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline.bold())
                    .foregroundStyle(teal)
            }
        }
    }

    // MARK: - Sign In

    private var signInButton: some View {
        Button {
            Task {
                await logIn()
            }
        } label: {
            HStack(spacing: 10) {

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(
                        systemName: "arrow.right.circle.fill"
                    )
                }

                Text(
                    isLoading
                        ? "Signing In..."
                        : "Sign In"
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
        .disabled(isLoading)
    }

    // MARK: - Create Account

    private var createAccountLink: some View {
        HStack(spacing: 5) {

            Text("Don't have an account?")
                .foregroundStyle(.secondary)

            NavigationLink {
                SignUpView()
            } label: {
                Text("Create Account")
                    .fontWeight(.semibold)
                    .foregroundStyle(teal)
            }
        }
        .font(.subheadline)
    }

    // MARK: - Supabase Authentication

    private func logIn() async {

        guard !isLoading else { return }

        let cleanEmail = email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        guard !cleanEmail.isEmpty,
              !password.isEmpty else {

            message = "Please enter your email and password."
            showAlert = true
            return
        }

        isLoading = true
        defer {
            isLoading = false
        }

        do {
            try await AuthManager.shared.signIn(
                email: cleanEmail,
                password: password
            )

            // Your existing AuthManager and ContentView
            // handle navigation after successful login.

        } catch {
            message = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
