import Testing
import Foundation
@testable import ExamPulse

struct FileStorageServiceTests {
    private func tempBaseDir() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ExamPulseTests-\(UUID().uuidString)", isDirectory: true)
    }

    @Test func persistFileCopiesFile() throws {
        let baseDir = tempBaseDir()
        defer { try? FileManager.default.removeItem(at: baseDir) }

        let service = FileStorageService(baseDirectory: baseDir)
        let examID = UUID()

        let sourceDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        let sourceFile = sourceDir.appendingPathComponent("test.pdf")
        try "PDF content".write(to: sourceFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: sourceDir) }

        let result = try service.persistFile(from: sourceFile, examID: examID)

        #expect(FileManager.default.fileExists(atPath: result.path))
        #expect(result.lastPathComponent == "test.pdf")
        #expect(result.path.contains(examID.uuidString))
    }

    @Test func persistFileOverwritesExisting() throws {
        let baseDir = tempBaseDir()
        defer { try? FileManager.default.removeItem(at: baseDir) }

        let service = FileStorageService(baseDirectory: baseDir)
        let examID = UUID()

        let sourceDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        let sourceFile = sourceDir.appendingPathComponent("test.pdf")
        defer { try? FileManager.default.removeItem(at: sourceDir) }

        try "Version 1".write(to: sourceFile, atomically: true, encoding: .utf8)
        _ = try service.persistFile(from: sourceFile, examID: examID)

        try "Version 2".write(to: sourceFile, atomically: true, encoding: .utf8)
        let result = try service.persistFile(from: sourceFile, examID: examID)

        let content = try String(contentsOf: result, encoding: .utf8)
        #expect(content == "Version 2")
    }

    @Test func deleteFilesRemovesExamDirectory() throws {
        let baseDir = tempBaseDir()
        defer { try? FileManager.default.removeItem(at: baseDir) }

        let service = FileStorageService(baseDirectory: baseDir)
        let examID = UUID()

        let sourceDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        let sourceFile = sourceDir.appendingPathComponent("test.pdf")
        try "data".write(to: sourceFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: sourceDir) }

        let result = try service.persistFile(from: sourceFile, examID: examID)
        #expect(FileManager.default.fileExists(atPath: result.path))

        service.deleteFiles(for: examID)

        #expect(!FileManager.default.fileExists(atPath: result.path))
    }

    @Test func deleteFilesNoOpForNonexistentID() {
        let baseDir = tempBaseDir()
        defer { try? FileManager.default.removeItem(at: baseDir) }

        let service = FileStorageService(baseDirectory: baseDir)
        service.deleteFiles(for: UUID())
    }
}
