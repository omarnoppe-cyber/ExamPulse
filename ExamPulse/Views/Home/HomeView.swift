import SwiftUI
import SwiftData

struct HomeView: View {
    private enum Route: Hashable {
        case createExam
        case uploadDocument
        case examDetail(Exam)
    }

    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var path: [Route] = []
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                heroSection
                quickActionsSection
                upcomingExamsSection
            }
            .navigationTitle("ExamPulse")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .createExam:
                    ExamSetupView()
                case .uploadDocument:
                    DocumentUploadView()
                case .examDetail(let exam):
                    ExamDetailView(exam: exam)
                }
            }
        }
    }

    private var heroSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.greeting())
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Upload study documents, generate study aids, and stay on track until exam day.")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
    }

    private var quickActionsSection: some View {
        Section("Quick Actions") {
            NavigationLink(value: Route.createExam) {
                Label("Create New Exam", systemImage: "plus.circle.fill")
            }

            NavigationLink(value: Route.uploadDocument) {
                Label("Upload Study Documents", systemImage: "doc.badge.plus")
            }
        }
    }

    private var upcomingExamsSection: some View {
        Section("Upcoming Exams") {
            if exams.isEmpty {
                ContentUnavailableView(
                    "No Exams Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Start by setting up an exam and uploading your study material.")
                )
            } else {
                ForEach(exams.prefix(5)) { exam in
                    NavigationLink(value: Route.examDetail(exam)) {
                        ExamRowView(exam: exam)
                    }
                }
            }
        }
    }
}
