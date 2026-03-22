import Foundation

protocol DocumentParsingService {
    func extractText(from fileURL: URL) async throws -> String
}

enum DocumentParsingError: LocalizedError {
    case unsupportedFormat(String)
    case parsingFailed(String)
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let ext):
            return "Unsupported file format: \(ext)"
        case .parsingFailed(let reason):
            return "Failed to parse document: \(reason)"
        case .fileNotFound:
            return "The document file could not be found."
        }
    }
}

enum DocumentParserFactory {
    static func parser(for url: URL) -> DocumentParsingService {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return PDFParsingService()
        case "docx":
            return DOCXParsingService()
        case "pptx":
            return PPTXParsingService()
        default:
            return UnsupportedParsingService(extension: url.pathExtension)
        }
    }
}

private struct UnsupportedParsingService: DocumentParsingService {
    let `extension`: String

    func extractText(from fileURL: URL) async throws -> String {
        throw DocumentParsingError.unsupportedFormat(self.extension)
    }
}
