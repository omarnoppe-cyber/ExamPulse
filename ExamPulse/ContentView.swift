import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var coordinator = AppCoordinator()

    var body: some View {
        if hasSeenOnboarding {
            mainTabs
        } else {
            NavigationStack {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exam.self, inMemory: true)
        .environment(\.dependencies, DependencyContainer())
}
