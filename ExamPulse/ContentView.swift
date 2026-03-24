import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall = false
    @Environment(\.dependencies) private var dependencies
    @State private var coordinator = AppCoordinator()
    @State private var showSplash = true

    private var isPro: Bool { dependencies.entitlementManager.isPro }

    private enum RootPhase: Int, Equatable {
        case splash
        case onboarding
        case paywall
        case main
    }

    private var rootPhase: RootPhase {
        if showSplash { return .splash }
        if !hasSeenOnboarding { return .onboarding }
        if !hasSeenPaywall && !isPro { return .paywall }
        return .main
    }

    var body: some View {
        ZStack {
            switch rootPhase {
            case .splash:
                SplashView(onFinished: finishSplash)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(1)

            case .onboarding:
                NavigationStack {
                    OnboardingView {
                        hasSeenOnboarding = true
                    }
                }
                .tint(.themePurple)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    )
                )
                .zIndex(0)

            case .paywall:
                NavigationStack {
                    PaywallView {
                        hasSeenPaywall = true
                    }
                }
                .tint(.themePurple)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    )
                )
                .zIndex(0)

            case .main:
                mainTabs
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        )
                    )
                    .zIndex(0)
            }
        }
        .animation(AppAnimation.root, value: rootPhase)
    }

    private func finishSplash() {
        showSplash = false
    }

    private var mainTabs: some View {
        TabView(selection: $coordinator.selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        AppCoordinator.AppTab.home.title,
                        systemImage: AppCoordinator.AppTab.home.systemImage
                    )
                }
                .tag(AppCoordinator.AppTab.home)

            NavigationStack {
                ProgressDashboardView()
            }
            .tabItem {
                Label(
                    AppCoordinator.AppTab.progress.title,
                    systemImage: AppCoordinator.AppTab.progress.systemImage
                )
            }
            .tag(AppCoordinator.AppTab.progress)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    AppCoordinator.AppTab.settings.title,
                    systemImage: AppCoordinator.AppTab.settings.systemImage
                )
            }
            .tag(AppCoordinator.AppTab.settings)
        }
        .animation(AppAnimation.tab, value: coordinator.selectedTab)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exam.self, inMemory: true)
        .environment(\.dependencies, DependencyContainer())
}
