import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                heroSection
                quickActionsSection
                upcomingExamsSection
            }
            .navigationTitle("ExamPulse")
            .sheet(isPresented: $viewModel.isShowingExamSetup) {
                NavigationStack {
                    ExamSetupView()
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
            Button {
                viewModel.isShowingExamSetup = true
            } label: {
                Label("Create New Exam", systemImage: "plus.circle.fill")
            }

            NavigationLink {
                DocumentUploadView()
            } label: {
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
                    NavigationLink {
                        ExamDetailView(exam: exam)
                    } label: {
                        ExamRowView(exam: exam)
                    }
                }
            }
        }
    }
}
