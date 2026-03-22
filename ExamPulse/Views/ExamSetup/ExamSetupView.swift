import SwiftUI

struct ExamSetupView: View {
    private enum Route: Hashable {
        case documentUpload
    }

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ExamSetupViewModel()

    var body: some View {
        Form {
            Section("Exam Details") {
                TextField("Exam Title", text: $viewModel.examTitle)

                DatePicker(
                    "Exam Date",
                    selection: $viewModel.examDate,
                    in: Date()...,
                    displayedComponents: .date
                )
            }

            Section("Next Step") {
                Text("Continue to upload your PDF, DOCX, or PPTX study materials.")
                    .foregroundStyle(.secondary)

                NavigationLink(value: Route.documentUpload) {
                    Text("Continue to Upload")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(!viewModel.canContinue)
            }
        }
        .navigationTitle("Exam Setup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .documentUpload:
                DocumentUploadView(
                    presetTitle: viewModel.examTitle,
                    presetExamDate: viewModel.examDate
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }
}
