import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var viewModel = ProgressViewModel()

    var body: some View {
        List {
            Section("Overview") {
                metricRow(
                    title: "Ready Exams",
                    value: "\(viewModel.readyExamCount(in: exams))",
                    systemImage: "checkmark.circle.fill",
                    color: .green
                )

                metricRow(
                    title: "Active Exams",
                    value: "\(viewModel.activeExamCount(in: exams))",
                    systemImage: "clock.fill",
                    color: .orange
                )

                metricRow(
                    title: "Flashcards Learned",
                    value: "\(viewModel.learnedFlashcards(in: exams))/\(viewModel.totalFlashcards(in: exams))",
                    systemImage: "rectangle.stack.fill.badge.plus",
                    color: .blue
                )
            }

            Section("Upcoming") {
                if exams.isEmpty {
                    Text("Your progress will appear here once you create an exam.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(exams.prefix(10)) { exam in
                        NavigationLink {
                            ExamDetailView(exam: exam)
                        } label: {
                            ExamRowView(exam: exam)
                        }
                    }
                }
            }
        }
        .navigationTitle("Progress")
    }

    private func metricRow(title: String, value: String, systemImage: String, color: Color) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundStyle(color)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
