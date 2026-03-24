import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// PDF, Word, and PowerPoint types allowed for exam uploads.
enum ExamDocumentContentTypes {
    static var all: [UTType] {
        [
            .pdf,
            UTType(filenameExtension: "docx")!,
            UTType(filenameExtension: "pptx")!
        ]
    }
}

/// Presents `UIDocumentPickerViewController` instead of SwiftUI's `.fileImporter`.
/// Avoids a known issue where dismissing the system file browser can leave the parent screen blank/white
/// when used inside a `NavigationStack`.
struct DocumentPickerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let allowedContentTypes: [UTType]
    var allowsMultipleSelection: Bool = true
    var onDocumentsPicked: ([URL]) -> Void = { _ in }

    func makeUIViewController(context: Context) -> DocumentPickerHostViewController {
        DocumentPickerHostViewController()
    }

    func updateUIViewController(_ uiViewController: DocumentPickerHostViewController, context: Context) {
        context.coordinator.parent = self

        guard isPresented else {
            if uiViewController.presentedViewController is UIDocumentPickerViewController {
                uiViewController.dismiss(animated: true)
            }
            return
        }

        guard uiViewController.presentedViewController == nil else { return }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = allowsMultipleSelection
        if #available(iOS 16.0, *) {
            picker.shouldShowFileExtensions = true
        }
        // Defer to next main-actor turn so the hosting controller is attached (avoids blank parent after dismiss).
        Task { @MainActor in
            guard uiViewController.presentedViewController == nil else { return }
            uiViewController.present(picker, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerRepresentable?

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent?.onDocumentsPicked(urls)
            parent?.isPresented = false
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent?.isPresented = false
        }
    }
}

/// Lightweight host used only to present the document picker modally.
final class DocumentPickerHostViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }
}

extension View {
    /// Invisible bridge that presents the system document picker when `isPresented` is `true`.
    func documentPickerBridge(
        isPresented: Binding<Bool>,
        allowedContentTypes: [UTType],
        allowsMultipleSelection: Bool = true,
        onDocumentsPicked: @escaping ([URL]) -> Void = { _ in }
    ) -> some View {
        background {
            DocumentPickerRepresentable(
                isPresented: isPresented,
                allowedContentTypes: allowedContentTypes,
                allowsMultipleSelection: allowsMultipleSelection,
                onDocumentsPicked: onDocumentsPicked
            )
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
