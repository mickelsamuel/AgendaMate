import SwiftUI

// SearchBar is a custom SwiftUI view that provides a search input field with a search icon.
// It allows users to input search text and displays a customizable background and text color.
struct SearchBar: View {
    @Binding var searchText: String     // A binding to the search text, allowing the parent view to react to changes.
    var backgroundColor: Color          // The background color of the search bar.
    var textColor: Color                // The color of the search text and search icon.
    var isDarkMode: Bool                // A flag indicating whether the app is in dark mode, used to adjust the background.

    var body: some View {
        HStack {
            // Search icon displayed to the left of the text field.
            Image(systemName: "magnifyingglass")
                .foregroundColor(textColor)  // The search icon color is determined by the provided textColor.
            
            // The search input field where users can type their search query.
            TextField("Search", text: $searchText)
                .foregroundColor(textColor)  // The text color inside the input field is set to the provided textColor.
        }
        .padding(10)  // Adds padding around the search bar's content for visual spacing.
        .background(isDarkMode ? backgroundColor : Color.white)  // Background color based on dark mode status.
        .cornerRadius(8)  // Applies rounded corners to the search bar.
    }
}
