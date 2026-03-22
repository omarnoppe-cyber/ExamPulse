import Foundation
import SwiftData
import Observation

@Observable
final class DocumentImportViewModel {
    var title = ""
    var examDate = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date()) ?? Date()
    var importedFileURLs: [URL] = []
    var isParsing = false
    var errorMessage: String?

    private let fileStorageService: FileStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let parserFactory: (URL) -> DocumentParsingService

    var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !importedFileURLs.isEmpty
            && !isParsing
    }

    init(
        fileStorageService: FileStorageServiceProtocol,
        notificationService: NotificationServiceProtocol,
        parserFactory: @escaping (URL) -> DocumentParsingService
    ) {
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
        self.parserFactory = parserFactory
    }

    func addFile(_ url: URL) {
        guard !importedFileURLs.contains(where: { $0.lastPathComponent == url.lastPathComponent }) else { return }
        importedFileURLs.append(url)
    }

    func removeFile(at index: Int) {
        importedFileURLs.remove(at: index)
    }

    @MainActor
    func createExam(context: ModelContext) async -> Exam? {
        guard canCreate else { return nil }

        isParsing = true
        errorMessage = nil

        let exam = Exam(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            examDate: examDate
        )
        exam.status = .parsing
        context.insert(exam)

        do {
            for fileURL in importedFileURLs {
                let persistedURL = try fileStorageService.persistFile(
                    from: fileURL, examID: exam.id
                )

                let parser = parserFactory(persistedURL)
                let rawText = try await parser.extractText(from: persistedURL)

                let document = Document(
                    filename: fileURL.lastPathComponent,
                    fileURL: persistedURL.path,
                    rawText: rawText
                )
                document.exam = exam
                context.insert(document)
            }

            exam.status = .new
            notificationService.scheduleDailyReminders(for: exam)

            isParsing = false
            return exam
        } catch {
            exam.status = .error
            errorMessage = error.localizedDescription
            isParsing = false
            return exam
        }
    }
}
