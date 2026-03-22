import Foundation
import Observation

@Observable
final class SummaryViewModel {
    let summaryText: String

    init(summaryText: String) {
        self.summaryText = summaryText
    }
}
