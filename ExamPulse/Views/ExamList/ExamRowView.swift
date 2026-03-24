import SwiftUI

struct ExamRowView: View {
    let exam: Exam

    var body: some View {
        HStack(spacing: 14) {
            statusIcon
            examInfo
            Spacer()
            trailingInfo
        }
        .padding(.vertical, 4)
    }

    // MARK: - Subviews

    private var statusIcon: some View {
        Group {
            switch exam.status {
            case .new:
                IconCircle(systemImage: "doc.badge.plus", color: .themePurple)
            case .parsing:
                ProgressView()
                    .frame(width: 40, height: 40)
            case .generating:
                IconCircle(systemImage: "sparkles", color: .themePeach)
            case .ready:
                IconCircle(systemImage: "checkmark", color: .green)
            case .error:
                IconCircle(systemImage: "exclamationmark.triangle.fill", color: .red)
            }
        }
    }

    private var examInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exam.title)
                .font(.headline)
                .foregroundStyle(.themeDark)
            Text(exam.examDate.shortFormatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var trailingInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(exam.examDate.relativeDayDescription)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(countdownColor)

            StatusPill(title: exam.status.displayName, color: exam.status.color)
        }
    }

    private var countdownColor: Color {
        let days = exam.daysUntilExam
        if days < 0 { return .secondary }
        if days <= 3 { return .red }
        if days <= 7 { return .orange }
        return .green
    }
}

// MARK: - ExamStatus display helpers

extension ExamStatus {
    var displayName: String {
        switch self {
        case .new: "New"
        case .parsing: "Parsing"
        case .generating: "Generating"
        case .ready: "Ready"
        case .error: "Error"
        }
    }

    var color: Color {
        switch self {
        case .new: .themePurple
        case .parsing, .generating: .themePeach
        case .ready: .green
        case .error: .red
        }
    }
}
