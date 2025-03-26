import Foundation

// A model representing a journal entry, conforming to Identifiable and Codable protocols.
// This struct is used to store the data of each journal entry, including a unique identifier, date, and the journal text.
struct JournalEntry: Identifiable, Codable {
    // A unique identifier for each journal entry, automatically generated as a UUID.
    var id = UUID()
    
    // The date when the journal entry was created or saved.
    var date: Date
    
    // The text content of the journal entry.
    var text: String
}
