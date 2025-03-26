import SwiftUI

// AsyncImage is a SwiftUI view that asynchronously loads an image from a URL and displays it.
// If the image is not yet loaded, a placeholder view is displayed instead.
struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader         // StateObject to manage the image loading process.
    private let placeholder: Placeholder                 // Placeholder view to display while the image is loading.
    private let image: (UIImage) -> Image                // Closure to transform the loaded UIImage into a SwiftUI Image.

    // Initializes the AsyncImage view with a URL, a placeholder view, and an optional image transformation closure.
    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url))   // Initialize the ImageLoader with the provided URL.
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)  // Start loading the image when the view appears.
    }

    // A view that displays either the loaded image or the placeholder, depending on the loading state.
    private var content: some View {
        Group {
            if let uiImage = loader.image {
                image(uiImage)               // Display the loaded image using the provided image closure.
            } else {
                placeholder                  // Display the placeholder view if the image is not yet loaded.
            }
        }
    }
}

// ImageLoader is a helper class responsible for downloading an image from a URL.
// It uses Combine's ObservableObject protocol to publish the loaded image once it's available.
private class ImageLoader: ObservableObject {
    @Published var image: UIImage?            // Published property that holds the loaded image.
    private let url: URL                      // The URL from which to load the image.

    // Initializes the ImageLoader with a URL.
    init(url: URL) {
        self.url = url
    }

    // Loads the image from the URL. If successful, the image is published on the main thread.
    func load() {
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return                              // If the image data can't be loaded, do nothing.
        }
        DispatchQueue.main.async {
            self.image = image                   // Publish the image on the main thread.
        }
    }
}
