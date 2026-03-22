import SwiftUI
import UniformTypeIdentifiers

struct DocumentImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: DocumentImportViewModel?
    @State private var showingFilePicker = false
    @State private var createdExam: Exam?

    var body: some View {
        Form {
            Section("Exam Details") {
                TextField("Exam Title", text: titleBinding)

                DatePicker(
                    "Exam Date",
                    selection: examDateBinding,
                    in: Date()...,
                    displayedComponents: .date
                )
            }

            Section {
                Button {
                    showingFilePicker = true
                } label: {
                    Label("Add Document", systemImage: "doc.badge.plus")
                }

                ForEach(Array((viewModel?.importedFileURLs ?? []).enumerated()), id: \.offset) { index, url in
                    HStack {
                        Image(systemName: iconName(for: url))
                            .foregroundStyle(.secondary)
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        Button(role: .destructive) {
                            viewModel?.removeFile(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("Documents")
            } footer: {
                Text("Supported formats: PDF, DOCX, PPTX")
            }

            if let error = viewModel?.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        if let exam = await viewModel?.createExam(context: modelContext) {
                            createdExam = exam
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel?.isParsing == true {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Processing...")
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Exam")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(!(viewModel?.canCreate ?? false))
            }
        }
        .navigationTitle("New Exam")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf, .init(filenameExtension: "docx")!, .init(filenameExtension: "pptx")!],
            allowsMultipleSelection: true
        ) { result in
            if let urls = try? result.get() {
                for url in urls {
                    viewModel?.addFile(url)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DocumentImportViewModel(
                    fileStorageService: dependencies.fileStorageService,
                    notificationService: dependencies.notificationService,
                    parserFactory: dependencies.documentParserFactory
                )
            }
        }
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { viewModel?.title ?? "" },
            set: { viewModel?.title = $0 }
        )
    }

    private var examDateBinding: Binding<Date> {
        Binding(
            get: { viewModel?.examDate ?? Date() },
            set: { viewModel?.examDate = $0 }
        )
    }

    private func iconName(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "doc.richtext"
        case "docx": return "doc.text"
        case "pptx": return "doc.text.image"
        default: return "doc"
        }
    }
}
