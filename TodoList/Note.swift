import Foundation

// A model representing a note, conforming to `Identifiable` and `Codable`.
// This struct is used to store and manage individual note data, including the note's title, content, and creation date.
struct Note: Identifiable, Codable {
    // Unique identifier for the note, automatically generated as a UUID.
    var id = UUID()
    
    // Title of the note, initialized with an empty string.
    var title: String = ""
    
    // Content of the note, initialized with an empty string.
    var content: String = ""
    
    // The date when the note was created or last updated, initialized with the current date.
    var date = Date()

    // A helper method to format the note's date into a user-friendly string format.
    func dateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")  // Ensures the date is formatted using the English locale.
        formatter.dateStyle = .medium  // Formats the date with a medium style (e.g., Jan 1, 2024).
        formatter.timeStyle = .none  // Time is not displayed in the formatted string.

        // Returns the formatted date as a string.
        return formatter.string(from: date)
    }
}
