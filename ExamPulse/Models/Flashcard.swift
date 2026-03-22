import Foundation
import SwiftData

@Model
final class Flashcard {
    var id: UUID
    var front: String
    var back: String
    var isLearned: Bool

    var topic: Topic?

    init(front: String, back: String, isLearned: Bool = false) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.isLearned = isLearned
    }
}
