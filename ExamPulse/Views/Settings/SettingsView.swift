import SwiftUI

struct SettingsView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var apiKey: String = ""
    @State private var showingKey = false
    @State private var saved = false
    @State private var viewModel = SettingsViewModel()

    private var manager: APIKeyManaging {
        dependencies.apiKeyManager
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    if showingKey {
                        TextField("sk-...", text: $apiKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("sk-...", text: $apiKey)
                            .textContentType(.password)
                    }

                    Button {
                        showingKey.toggle()
                    } label: {
                        Image(systemName: showingKey ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button("Save API Key") {
                    manager.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    saved = true
                }
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text("OpenAI API Key")
            } footer: {
                if saved {
                    Text("API key saved securely to Keychain.")
                        .foregroundStyle(.green)
                } else {
                    Text("Your key is stored securely in the device Keychain and never leaves your device except to call the OpenAI API.")
                }
            }

            if manager.hasAPIKey {
                Section {
                    Button("Remove API Key", role: .destructive) {
                        manager.apiKey = nil
                        apiKey = ""
                        saved = false
                    }
                }
            }

            Section("About") {
                HStack {
                    Text("App")
                    Spacer()
                    Text(viewModel.appName)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.versionString)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            apiKey = manager.apiKey ?? ""
        }
    }
}
