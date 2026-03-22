import SwiftUI
import SwiftData

struct ExamListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var viewModel: ExamListViewModel?
    @State private var showingPaywall = false

    private var canCreateExam: Bool {
        dependencies.entitlementManager.isPro
            || exams.count < dependencies.entitlementManager.maxFreeExams
    }

    var body: some View {
        NavigationStack {
            Group {
                if exams.isEmpty {
                    emptyState
                } else {
                    examList
                }
            }
            .navigationTitle("ExamPulse")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if canCreateExam {
                            viewModel?.showingNewExam = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: showingNewExamBinding) {
                NavigationStack {
                    DocumentImportView()
                }
            }
            .sheet(isPresented: $showingPaywall) {
                NavigationStack {
                    PaywallView()
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ExamListViewModel(
                        notificationService: dependencies.notificationService,
                        fileStorageService: dependencies.fileStorageService
                    )
                }
            }
        }
    }

    private var showingNewExamBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.showingNewExam ?? false },
            set: { viewModel?.showingNewExam = $0 }
        )
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Exams Yet", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Upload a study document and set an exam date to get started.")
        } actions: {
            Button("Create Your First Exam") {
                viewModel?.showingNewExam = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var examList: some View {
        List {
            ForEach(exams) { exam in
                NavigationLink(value: exam) {
                    ExamRowView(exam: exam)
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    viewModel?.deleteExam(exams[index], context: modelContext)
                }
            }
        }
        .navigationDestination(for: Exam.self) { exam in
            ExamDetailView(exam: exam)
        }
    }
}
