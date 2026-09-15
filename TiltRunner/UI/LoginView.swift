import SwiftUI

struct LoginView: View {
    @ObservedObject private var authManager = AuthManager.shared

    @State private var mode: Mode = .login
    @State private var username = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private enum Mode: String, CaseIterable {
        case login = "Log In"
        case register = "Register"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("TiltRunner")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 240)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: 240)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 240)
                }

                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text(mode.rawValue)
                            .frame(maxWidth: 220)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSubmit || isSubmitting)

                Spacer()
            }
            .padding()
        }
    }

    private var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    private func submit() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let session: (token: String, username: String)
                switch mode {
                case .login:
                    session = try await AuthService.logIn(username: trimmedUsername, password: password)
                case .register:
                    session = try await AuthService.register(username: trimmedUsername, password: password)
                }
                authManager.setSession(token: session.token, username: session.username)
                isSubmitting = false
            } catch {
                isSubmitting = false
                errorMessage = mode == .login
                    ? "Couldn't log in. Check your username and password."
                    : "Couldn't register. Username may be taken, or password too short (6+ characters)."
            }
        }
    }
}
