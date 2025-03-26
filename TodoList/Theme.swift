import SwiftUI

// The Theme struct defines the color scheme for both light and dark modes within the app.
// It includes primary and secondary colors, background colors, text colors, and a contrast color.
struct Theme {
    let lightPrimaryColor: Color          // Primary color for light mode.
    let darkPrimaryColor: Color           // Primary color for dark mode.
    let lightSecondaryColor: Color        // Secondary color for light mode.
    let darkSecondaryColor: Color         // Secondary color for dark mode.
    let lightBackgroundColor: Color       // Background color for light mode.
    let darkBackgroundColor: Color        // Background color for dark mode.
    let lightTextColor: Color             // Text color for light mode.
    let darkTextColor: Color              // Text color for dark mode.
    let contrastColor: Color              // A contrasting color that stands out against both light and dark backgrounds.
}

// The AppTheme enum represents a selection of predefined color themes for the app.
// Each case provides a different color palette with light and dark mode variants.
enum AppTheme: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    case orange = "Orange"
    case purple = "Purple"
    case yellow = "Yellow"
    case pink = "Pink"
    case teal = "Teal"
    case brown = "Brown"

    // The id property conforms to the Identifiable protocol, allowing the theme to be used in lists and selections.
    var id: String { self.rawValue }

    // The theme property returns a Theme struct based on the selected case, defining the colors for light and dark modes.
    var theme: Theme {
        switch self {
        case .blue:
            return Theme(
                lightPrimaryColor: .blue,
                darkPrimaryColor: .blue,
                lightSecondaryColor: .blue.opacity(0.5),
                darkSecondaryColor: .blue.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .red:
            return Theme(
                lightPrimaryColor: .red,
                darkPrimaryColor: .red,
                lightSecondaryColor: .red.opacity(0.5),
                darkSecondaryColor: .red.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .green:
            return Theme(
                lightPrimaryColor: .green,
                darkPrimaryColor: .green,
                lightSecondaryColor: .green.opacity(0.5),
                darkSecondaryColor: .green.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .orange:
            return Theme(
                lightPrimaryColor: .orange,
                darkPrimaryColor: .orange,
                lightSecondaryColor: .orange.opacity(0.5),
                darkSecondaryColor: .orange.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .purple:
            return Theme(
                lightPrimaryColor: .purple,
                darkPrimaryColor: .purple,
                lightSecondaryColor: .purple.opacity(0.5),
                darkSecondaryColor: .purple.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .yellow:
            return Theme(
                lightPrimaryColor: .yellow,
                darkPrimaryColor: .yellow,
                lightSecondaryColor: .yellow.opacity(0.5),
                darkSecondaryColor: .yellow.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .pink:
            return Theme(
                lightPrimaryColor: .pink,
                darkPrimaryColor: .pink,
                lightSecondaryColor: .pink.opacity(0.5),
                darkSecondaryColor: .pink.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .teal:
            return Theme(
                lightPrimaryColor: .teal,
                darkPrimaryColor: .teal,
                lightSecondaryColor: .teal.opacity(0.5),
                darkSecondaryColor: .teal.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        case .brown:
            return Theme(
                lightPrimaryColor: .brown,
                darkPrimaryColor: .brown,
                lightSecondaryColor: .brown.opacity(0.5),
                darkSecondaryColor: .brown.opacity(0.5),
                lightBackgroundColor: .white,
                darkBackgroundColor: .black,
                lightTextColor: .black,
                darkTextColor: .white,
                contrastColor: .white
            )
        }
    }
}
