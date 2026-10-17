
import SwiftUI
import Supabase

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Account")
                .font(.largeTitle.bold())

            Text("Join Care Companion")
                .foregroundStyle(.secondary)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password (6+ characters)", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                Task { await signUp() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .disabled(isLoading)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("Sign Up")
    }

    private func signUp() async {
        guard password.count >= 6 else {
            message = "Password must have at least 6 characters."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await SupabaseManager.client.auth.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            message = "Account created! Check your email if confirmation is required."
        } catch {
            message = error.localizedDescription
        }
    }
}
