import Foundation
import Observation

@Observable
final class DocumentUploadViewModel {
    let supportedFormats = ["PDF", "DOCX", "PPTX"]
    var helperText = "Use the full import flow below to persist files and generate study content."
}
