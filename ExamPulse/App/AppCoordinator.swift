import Foundation
import Observation

@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .home

    enum AppTab: Int, CaseIterable, Hashable {
        case home
        case progress
        case settings

        var title: String {
            switch self {
            case .home:
                return "Home"
            case .progress:
                return "Progress"
            case .settings:
                return "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .home:
                return "house.fill"
            case .progress:
                return "chart.line.uptrend.xyaxis"
            case .settings:
                return "gearshape"
            }
        }
    }
}
