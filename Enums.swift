import Foundation

// An enumeration representing the different options for sorting tasks.
// Conforms to `CaseIterable` for iterating through all cases and `Codable` for easy encoding/decoding to and from data formats.
enum SortOption: String, CaseIterable, Codable {
    case title = "Title"          // Sort tasks alphabetically by title.
    case dueDate = "Due Date"     // Sort tasks by their due date.
    case priority = "Priority"    // Sort tasks by priority level (low, medium, high).
    case tags = "Tags"            // Sort tasks by tags, sorted alphabetically.
    case custom = "Custom"        // Sort tasks based on a user-defined custom order.
}

// An enumeration representing the frequency of task recurrence.
// Conforms to `CaseIterable` for iterating through all cases and `Codable` for easy encoding/decoding to and from data formats.
enum RecurrenceFrequency: String, Codable, CaseIterable {
    case none = "None"            // The task does not recur.
    case daily = "Daily"          // The task recurs every day.
    case weekly = "Weekly"        // The task recurs every week.
    case monthly = "Monthly"      // The task recurs every month.
    case yearly = "Yearly"        // The task recurs every year.
}
