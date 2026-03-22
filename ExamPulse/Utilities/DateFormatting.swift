import Foundation

extension Date {
    var relativeDayDescription: String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: self)).day ?? 0

        switch days {
        case ..<0:
            return "Past due"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "In \(days) days"
        }
    }

    var shortFormatted: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }
}
