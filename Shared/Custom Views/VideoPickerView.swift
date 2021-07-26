import SwiftUI

public struct VideoPickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let onVideoPicked: (Data) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, onVideoPicked: @escaping (Data) -> Void) {
        self.sourceType = sourceType
        self.onVideoPicked = onVideoPicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onVideoPicked: self.onVideoPicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onVideoPicked: (Data) -> Void

        init(onDismiss: @escaping () -> Void, onVideoPicked: @escaping (Data) -> Void) {
            self.onDismiss = onDismiss
            self.onVideoPicked = onVideoPicked
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let data = try? Data(contentsOf: url) {
                self.onVideoPicked(data)
            }
            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}
