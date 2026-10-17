
import SwiftUI
import Supabase

struct ForgotPasswordView: View {

    @State private var email = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var showAlert = false
    @State private var emailSent = false

    private let teal = Color.teal

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                Spacer(minLength: 35)

                Image(systemName: "lock.rotation")
                    .font(.system(size: 65))
                    .foregroundStyle(teal)
                    .padding(.bottom, 10)

                Text("Forgot Password?")
                    .font(.largeTitle.bold())

                Text(
                    "Enter your email address and we'll send you a link to reset your password."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {

                    Text("Email Address")
                        .font(.headline)

                    TextField(
                        "Enter your email address",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .disabled(isLoading)

                }
                .padding(.top, 12)

                Button {
                    Task {
                        await sendResetEmail()
                    }
                } label: {

                    HStack(spacing: 10) {

                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "envelope.fill")
                        }

                        Text(
                            isLoading
                            ? "Sending..."
                            : "Send Reset Email"
                        )
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(teal)
                    .foregroundStyle(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                }
                .disabled(isLoading || email.isEmpty)

                if emailSent {

                    VStack(spacing: 12) {

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)

                        Text("Check Your Email")
                            .font(.title3.bold())

                        Text(
                            "If an account exists for this email, you should receive a password reset link. Check your spam folder too."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.green.opacity(0.08)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }

                Spacer(minLength: 30)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reset Password")
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

    // MARK: - Send Password Reset Email

    private func sendResetEmail() async {

        let cleanEmail = email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        guard cleanEmail.contains("@"),
              cleanEmail.contains(".") else {

            message = "Please enter a valid email address."
            showAlert = true
            return
        }

        isLoading = true
        emailSent = false

        defer {
            isLoading = false
        }

        do {

            let redirectURL = URL(
                string: "carecompanion://reset-password"
            )!

            try await SupabaseManager.client.auth
                .resetPasswordForEmail(
                    cleanEmail,
                    redirectTo: redirectURL
                )

            emailSent = true

            message =
                "Password reset requested. Please check your email."

            showAlert = true

        } catch {

            message =
                "Unable to send reset email: \(error.localizedDescription)"

            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
