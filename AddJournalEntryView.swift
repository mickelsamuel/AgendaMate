import SwiftUI

// A view that allows the user to add a new journal entry by selecting a date and entering text.
// This view uses @Binding to pass and update the journal entries array from the parent view.
struct AddJournalEntryView: View {
    // A binding to the list of journal entries, allowing the parent view to pass in and update the list of journal entries.
    @Binding var journalEntries: [JournalEntry]
    
    // State variable to hold the user's input for the journal text.
    @State private var journalText = ""
    
    // State variable to hold the selected date for the journal entry.
    @State private var selectedDate = Date()
    
    // Environment variable to control the presentation mode (e.g., dismiss the current view).
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // The main UI of the view, which includes a date picker and a text editor for adding a journal entry.
        NavigationView {
            VStack {
                // DatePicker for selecting the date associated with the journal entry.
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())  // Uses a graphical style for selecting the date.
                    .padding()

                // TextEditor for writing the journal entry text.
                TextEditor(text: $journalText)
                    .padding()
                    .border(Color.gray, width: 1)

                // Save button to save the journal entry.
                .navigationTitle("Add Journal Entry")
                .navigationBarItems(trailing: Button("Save") {
                    saveJournalEntry()
                })
            }
        }
    }

    // Private function to save the journal entry by appending it to the journalEntries array.
    private func saveJournalEntry() {
        // Create a new journal entry using the selected date and text.
        let newEntry = JournalEntry(date: selectedDate, text: journalText)
        
        // Append the new journal entry to the journalEntries array.
        journalEntries.append(newEntry)
        
        // Dismiss the current view after saving the entry.
        presentationMode.wrappedValue.dismiss()
    }
}
