import SwiftUI
import UIKit

// A SwiftUI wrapper around UIKit's UIImagePickerController, allowing the user to pick an image from their photo library.
// It uses UIViewControllerRepresentable to integrate the UIKit component into SwiftUI.
struct CustomImagePicker: UIViewControllerRepresentable {
    // A binding to hold the selected image, allowing the parent view to update when the user picks an image.
    @Binding var image: UIImage?
    
    // Environment variable to control the presentation mode, allowing the picker to dismiss itself after an image is chosen.
    @Environment(\.presentationMode) var presentationMode

    // Creates and returns the Coordinator object that will act as the delegate for the UIImagePickerController.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // Creates the UIImagePickerController and sets the coordinator as its delegate.
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // Sets the coordinator as the delegate.
        return picker  // Returns the configured picker.
    }

    // This function is required by UIViewControllerRepresentable but is not used in this case.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CustomImagePicker>) {
    }

    // A Coordinator class to handle delegate methods from UIImagePickerController, including image picking and dismissal.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CustomImagePicker  // A reference to the parent CustomImagePicker view.

        // Initializes the Coordinator with a reference to the parent CustomImagePicker view.
        init(parent: CustomImagePicker) {
            self.parent = parent
        }

        // Delegate method that is called when the user selects an image from the picker.
        // It retrieves the selected image, assigns it to the bound `image` property, and then dismisses the picker.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage  // Sets the selected image.
            }
            parent.presentationMode.wrappedValue.dismiss()  // Dismisses the picker.
        }
    }
}
