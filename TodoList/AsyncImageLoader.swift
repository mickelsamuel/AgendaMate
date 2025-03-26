import SwiftUI

// AsyncImageLoader is a SwiftUI view that asynchronously loads an image from a URL and displays it.
// If the image is not yet loaded, a placeholder image is shown.
struct AsyncImageLoader: View {
    @StateObject private var loader: ImageLoader  // StateObject that manages the image loading process.
    private let placeholder: Image                // Placeholder image to be displayed while the image is loading.

    // Initializes the AsyncImageLoader with a URL and an optional placeholder image.
    // The default placeholder is a system image of a photo icon.
    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))  // Initialize ImageLoader with the given URL.
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)  // Starts loading the image when the view appears.
    }

    // The content view displays either the loaded image or the placeholder, depending on the loading state.
    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)         // Display the loaded image.
                    .resizable()              // Makes the image resizable.
            } else {
                placeholder                   // Display the placeholder if the image has not been loaded yet.
            }
        }
    }
}

// ImageLoader is a helper class that handles asynchronously downloading an image from a URL.
// It uses Combine's ObservableObject protocol to publish the loaded image when it becomes available.
private class ImageLoader: ObservableObject {
    @Published var image: UIImage?  // Published property to store the loaded image, allowing updates in the view.
    private let url: URL            // The URL from which the image will be fetched.

    // Initializes the ImageLoader with a URL.
    init(url: URL) {
        self.url = url
    }

    // Loads the image asynchronously from the URL.
    func load() {
        // Create a data task to fetch the image from the provided URL.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check if data was successfully received and attempt to create a UIImage from it.
            guard let data = data, let image = UIImage(data: data) else { return }
            // Publish the image on the main thread to update the SwiftUI view.
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()  // Start the network task to download the image.
    }
}
