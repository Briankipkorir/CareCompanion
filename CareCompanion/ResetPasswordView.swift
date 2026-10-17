
import SwiftUI

struct ResetPasswordView: View {

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var showAlert = false
    @State private var resetSucceeded = false

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 70))
                .foregroundStyle(.teal)

            Text("Reset Password")
                .font(.largeTitle.bold())

            Text("Create a new password for your Care Companion account.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            SecureField("New Password", text: $newPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm New Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    await resetPassword()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }

                    Text(
                        isLoading
                        ? "Updating..."
                        : "Update Password"
                    )
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.teal)
                .foregroundStyle(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
            .disabled(isLoading || resetSucceeded)

            Spacer()
        }
        .padding(24)
        .alert("Care Companion", isPresented: $showAlert) {
            Button("OK") {
                if resetSucceeded {
                    AuthManager.shared.needsPasswordReset = false
                }
            }
        } message: {
            Text(message)
        }
    }

    private func resetPassword() async {

        guard newPassword.count >= 8 else {
            message = "Password must contain at least 8 characters."
            showAlert = true
            return
        }

        guard newPassword == confirmPassword else {
            message = "Passwords do not match."
            showAlert = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthManager.shared.updatePassword(
                newPassword
            )

            resetSucceeded = true
            message = "Your password has been updated successfully!"

        } catch {
            message = "Unable to reset password: \(error.localizedDescription)"
        }

        showAlert = true
    }
}

#Preview {
    ResetPasswordView()
}
