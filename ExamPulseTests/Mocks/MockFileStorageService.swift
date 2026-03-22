import Foundation
@testable import ExamPulse

final class MockFileStorageService: FileStorageServiceProtocol {
    var persistedFiles: [(source: URL, examID: UUID)] = []
    var deletedExamIDs: [UUID] = []
    var errorToThrow: Error?

    func persistFile(from sourceURL: URL, examID: UUID) throws -> URL {
        if let error = errorToThrow { throw error }
        persistedFiles.append((sourceURL, examID))
        return sourceURL
    }

    func deleteFiles(for examID: UUID) {
        deletedExamIDs.append(examID)
    }
}
