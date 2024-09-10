import Foundation

// A class responsible for managing the collection of notes. It handles the addition, deletion, updating, and sorting of notes,
// as well as saving and loading notes from persistent storage (UserDefaults). The class also supports exporting notes to a CSV format.
class NotesManager: ObservableObject {
    // Published array of notes. This allows SwiftUI views to reactively update when the notes array changes.
    @Published var notes: [Note] = []

    // Initializer that loads notes from persistent storage when the manager is initialized.
    init() {
        loadNotes()
    }

    // Adds a new note to the notes array and saves the updated notes to persistent storage.
    func add(_ note: Note) {
        notes.append(note)
        saveNotes()
    }

    // Deletes the specified note from the notes array if it exists, and saves the updated notes.
    func delete(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotes()
        }
    }

    // Updates an existing note in the notes array and saves the changes.
    func update(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }

    // Reorders notes within the array according to the user's drag-and-drop action, and saves the changes.
    func moveNotes(from source: IndexSet, to destination: Int) {
        notes.move(fromOffsets: source, toOffset: destination)
        saveNotes()
    }

    // Returns the notes array sorted according to the specified sort option (by title, date, or custom order).
    func sortedNotes(by sortOption: NotesSortOption) -> [Note] {
        switch sortOption {
        case .title:
            return notes.sorted { $0.title < $1.title }
        case .date:
            return notes.sorted { $0.date < $1.date }
        case .custom:
            return notes  // Custom order is simply the current order of notes in the array.
        }
    }

    // Private method to save the notes array to UserDefaults as a JSON-encoded data.
    private func saveNotes() {
        if let encodedData = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encodedData, forKey: "notes")
        }
    }

    // Private method to load the notes array from UserDefaults, decoding the JSON data back into an array of Note objects.
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "notes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decodedNotes
        }
    }

    // Exports the notes array to a CSV format string, including columns for the note title, date, and content.
    func exportNotes() -> String {
        var csvString = "Title,Date,Content\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        // Append each note's data as a CSV row.
        for note in notes {
            let dateString = dateFormatter.string(from: note.date)
            csvString.append("\(note.title),\(dateString),\(note.content)\n")
        }
        
        return csvString  // Return the formatted CSV string.
    }
}
