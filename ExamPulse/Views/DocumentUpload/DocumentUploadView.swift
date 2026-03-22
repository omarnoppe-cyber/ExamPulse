import SwiftUI

struct DocumentUploadView: View {
    let presetTitle: String?
    let presetExamDate: Date?

    @State private var viewModel = DocumentUploadViewModel()

    init(presetTitle: String? = nil, presetExamDate: Date? = nil) {
        self.presetTitle = presetTitle
        self.presetExamDate = presetExamDate
    }

    var body: some View {
        List {
            if let presetTitle {
                Section("Exam Setup") {
                    LabeledContent("Title", value: presetTitle)

                    if let presetExamDate {
                        LabeledContent("Exam Date", value: presetExamDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }

            Section("Supported Files") {
                ForEach(viewModel.supportedFormats, id: \.self) { format in
                    Label(format, systemImage: "doc")
                }
            }

            Section("Upload Flow") {
                Text(viewModel.helperText)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    DocumentImportView()
                } label: {
                    Label("Open Full Document Import", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Document Upload")
        .navigationBarTitleDisplayMode(.inline)
    }
}
