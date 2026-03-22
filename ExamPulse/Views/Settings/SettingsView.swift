import SwiftUI

struct SettingsView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var apiKey: String = ""
    @State private var showingKey = false
    @State private var saved = false
    @State private var viewModel = SettingsViewModel()

    private var keyManager: APIKeyManaging { dependencies.apiKeyManager }
    private var isPro: Bool { dependencies.entitlementManager.isPro }

    var body: some View {
        Form {
            apiKeySection
            if keyManager.hasAPIKey { removeKeySection }
            subscriptionSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { apiKey = keyManager.apiKey ?? "" }
    }
}

// MARK: - API Key

private extension SettingsView {
    var apiKeySection: some View {
        Section {
            HStack {
                Group {
                    if showingKey {
                        TextField("sk-...", text: $apiKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("sk-...", text: $apiKey)
                            .textContentType(.password)
                    }
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
                keyManager.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                saved = true
            }
            .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } header: {
            Text("OpenAI API Key")
        } footer: {
            Text(saved
                 ? "API key saved securely to Keychain."
                 : "Your key is stored securely in the device Keychain and never leaves your device except to call the OpenAI API."
            )
            .foregroundStyle(saved ? .green : .secondary)
        }
    }

    var removeKeySection: some View {
        Section {
            Button("Remove API Key", role: .destructive) {
                keyManager.apiKey = nil
                apiKey = ""
                saved = false
            }
        }
    }
}

// MARK: - Subscription

private extension SettingsView {
    var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Text("Plan")
                Spacer()
                StatusPill(title: isPro ? "Pro" : "Free", color: isPro ? .blue : .secondary)
            }

            if !isPro {
                NavigationLink {
                    PaywallView()
                } label: {
                    Label("Upgrade to Pro", systemImage: "sparkles")
                }
            }

            Button("Restore Purchases") {
                Task { await dependencies.storeService.restorePurchases() }
            }
        }
    }
}

// MARK: - About

private extension SettingsView {
    var aboutSection: some View {
        Section("About") {
            aboutRow(title: "App", value: viewModel.appName)
            aboutRow(title: "Version", value: viewModel.versionString)
        }
    }

    func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
