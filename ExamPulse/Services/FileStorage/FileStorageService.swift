import Foundation

protocol FileStorageServiceProtocol {
    func persistFile(from sourceURL: URL, examID: UUID) throws -> URL
    func deleteFiles(for examID: UUID)
}

struct FileStorageService: FileStorageServiceProtocol {
    private let fileManager: FileManager
    private let baseDirectory: URL

    init(fileManager: FileManager = .default, baseDirectory: URL? = nil) {
        self.fileManager = fileManager
        self.baseDirectory = baseDirectory
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("ExamPulse/Documents", isDirectory: true)
    }

    func persistFile(from sourceURL: URL, examID: UUID) throws -> URL {
        let examDir = baseDirectory.appendingPathComponent(examID.uuidString, isDirectory: true)
        try fileManager.createDirectory(at: examDir, withIntermediateDirectories: true)

        let destination = examDir.appendingPathComponent(sourceURL.lastPathComponent)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessing { sourceURL.stopAccessingSecurityScopedResource() }
        }

        try fileManager.copyItem(at: sourceURL, to: destination)
        return destination
    }

    func deleteFiles(for examID: UUID) {
        let examDir = baseDirectory.appendingPathComponent(examID.uuidString, isDirectory: true)
        try? fileManager.removeItem(at: examDir)
    }
}
