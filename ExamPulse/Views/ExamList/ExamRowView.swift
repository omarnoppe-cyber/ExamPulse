import SwiftUI

struct ExamRowView: View {
    let exam: Exam

    var body: some View {
        HStack(spacing: 14) {
            statusIcon
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(exam.title)
                    .font(.headline)

                Text(exam.examDate.shortFormatted)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(exam.examDate.relativeDayDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(daysColor)

                statusBadge
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch exam.status {
        case .new:
            Image(systemName: "doc.badge.plus")
                .font(.title2)
                .foregroundStyle(.blue)
        case .parsing:
            ProgressView()
        case .generating:
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.orange)
                .symbolEffect(.pulse)
        case .ready:
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch exam.status {
        case .new:
            Text("New")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.15), in: Capsule())
                .foregroundStyle(.blue)
        case .parsing:
            Text("Parsing")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.orange.opacity(0.15), in: Capsule())
                .foregroundStyle(.orange)
        case .generating:
            Text("Generating")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.orange.opacity(0.15), in: Capsule())
                .foregroundStyle(.orange)
        case .ready:
            Text("Ready")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.green.opacity(0.15), in: Capsule())
                .foregroundStyle(.green)
        case .error:
            Text("Error")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.red.opacity(0.15), in: Capsule())
                .foregroundStyle(.red)
        }
    }

    private var daysColor: Color {
        let days = exam.daysUntilExam
        if days < 0 { return .secondary }
        if days <= 3 { return .red }
        if days <= 7 { return .orange }
        return .green
    }
}
