import Foundation
import SwiftData

@Model
final class Summary {
    var id: UUID
    var content: String

    var exam: Exam?

    init(content: String) {
        self.id = UUID()
        self.content = content
    }
}
