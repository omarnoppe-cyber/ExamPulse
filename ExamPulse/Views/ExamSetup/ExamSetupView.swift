import SwiftUI

struct ExamSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: DocumentImportViewModel?
    @State private var showingFilePicker = false

    var body: some View {
        ZStack {
            Color.themeCanvas.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    titleField
                    dateField
                    documentsSection
                    if let error = viewModel?.errorMessage { errorBanner(error) }
                    createButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("New Exam")
        .navigationBarTitleDisplayMode(.inline)
        .documentPickerBridge(
            isPresented: $showingFilePicker,
            allowedContentTypes: ExamDocumentContentTypes.all,
            allowsMultipleSelection: true
        ) { urls in
            for url in urls { viewModel?.addFile(url) }
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
}

// MARK: - Header

private extension ExamSetupView {
    var headerSection: some View {
        VStack(spacing: 8) {
            IconCircle(systemImage: "doc.badge.plus", color: .themePurple, size: 56)

            Text("Create a new exam")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.themeDark)

            Text("Add your study materials and we'll generate\nflashcards, quizzes, and summaries for you.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Fields

private extension ExamSetupView {
    var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EXAM TITLE")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(0.6)

            TextField("e.g. Biology Midterm", text: titleBinding)
                .font(.body)
                .padding(14)
                .background(.themeSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        }
    }

    var dateField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EXAM DATE")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(0.6)

            DatePicker(
                "",
                selection: examDateBinding,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themeSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
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
}

// MARK: - Documents

private extension ExamSetupView {
    var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STUDY MATERIALS")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(0.6)

            let files = viewModel?.importedFileURLs ?? []

            if files.isEmpty {
                emptyDropZone
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(files.enumerated()), id: \.offset) { index, url in
                        if index > 0 { Divider().padding(.leading, 50) }
                        fileRow(url, at: index)
                    }
                }
                .background(.themeSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)

                addMoreButton
            }
        }
    }

    var emptyDropZone: some View {
        Button {
            showingFilePicker = true
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.themePurple.opacity(0.08))
                        .frame(width: 56, height: 56)
                    Image(systemName: "arrow.up.doc")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.themePurple)
                }

                Text("Upload Documents")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.themeDark)

                Text("PDF, DOCX, or PPTX")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.themePurple.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [8, 5]))
            )
            .background(.themeSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    func fileRow(_ url: URL, at index: Int) -> some View {
        HStack(spacing: 12) {
            IconCircle(systemImage: iconName(for: url), color: .themePeach, size: 36)

            Text(url.lastPathComponent)
                .font(.subheadline)
                .foregroundStyle(.themeDark)
                .lineLimit(1)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel?.removeFile(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    var addMoreButton: some View {
        Button {
            showingFilePicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.themePurple)
                Text("Add more files")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.themePurple)
            }
        }
        .buttonStyle(.plain)
    }

    func iconName(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": "doc.richtext"
        case "docx": "doc.text"
        case "pptx": "doc.text.image"
        default: "doc"
        }
    }
}

// MARK: - Error

private extension ExamSetupView {
    func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Create Button

private extension ExamSetupView {
    var createButton: some View {
        Button {
            Task {
                if let _ = await viewModel?.createExam(context: modelContext) {
                    dismiss()
                }
            }
        } label: {
            Group {
                if viewModel?.isParsing == true {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small).tint(.white)
                        Text("Processing...")
                    }
                } else {
                    Label("Create Exam", systemImage: "sparkles")
                }
            }
        }
        .buttonStyle(.primary)
        .disabled(!(viewModel?.canCreate ?? false))
        .padding(.top, 4)
    }
}
