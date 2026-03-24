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
        ScrollView {
            VStack(spacing: 16) {
                apiKeySection
                if keyManager.hasAPIKey { removeKeySection }
                subscriptionSection
                aboutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .themeCanvas()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { apiKey = keyManager.apiKey ?? "" }
    }
}

// MARK: - API Key

private extension SettingsView {
    var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("OpenAI API Key").font(.headline).foregroundStyle(.themeDark)
            } icon: {
                Image(systemName: "key.fill").foregroundStyle(.themePurple)
            }

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
                .padding(12)
                .background(.themeSurfaceElevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    showingKey.toggle()
                } label: {
                    Image(systemName: showingKey ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            Button {
                keyManager.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                saved = true
            } label: {
                Text("Save API Key")
            }
            .buttonStyle(.primary)
            .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Text(saved
                 ? "API key saved securely to Keychain."
                 : "Your key is stored securely in the device Keychain and never leaves your device except to call the OpenAI API."
            )
            .font(.caption)
            .foregroundStyle(saved ? .green : .secondary)
        }
        .softCard()
    }

    var removeKeySection: some View {
        Button("Remove API Key", role: .destructive) {
            keyManager.apiKey = nil
            apiKey = ""
            saved = false
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }
}

// MARK: - Subscription

private extension SettingsView {
    var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Subscription").font(.headline).foregroundStyle(.themeDark)
            } icon: {
                Image(systemName: "creditcard.fill").foregroundStyle(.themePurple)
            }

            HStack {
                Text("Plan").foregroundStyle(.secondary)
                Spacer()
                StatusPill(title: isPro ? "Pro" : "Free", color: isPro ? .themePurple : .secondary)
            }

            if !isPro {
                NavigationLink {
                    PaywallView()
                } label: {
                    DisclosureRow(title: "Upgrade to Pro", subtitle: "Unlock unlimited features") {
                        IconCircle(systemImage: "sparkles", color: .themePurple)
                    }
                }
            }

            Button("Restore Purchases") {
                Task { await dependencies.storeService.restorePurchases() }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .softCard()
    }
}

// MARK: - About

private extension SettingsView {
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("About").font(.headline).foregroundStyle(.themeDark)
            } icon: {
                Image(systemName: "info.circle.fill").foregroundStyle(.themePurple)
            }

            aboutRow(title: "App", value: viewModel.appName)
            aboutRow(title: "Version", value: viewModel.versionString)
        }
        .softCard()
    }

    func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium).foregroundStyle(.themeDark)
        }
    }
}
