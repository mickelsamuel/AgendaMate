import SwiftUI
import UIKit

// A view for displaying and editing the details of a note, including the title and content.
// It also supports sharing, saving, and deleting notes, with dynamic behavior for new and existing notes.
struct NoteDetailView: View {
    // Environment variable to control the presentation mode, allowing for the view to be dismissed.
    @Environment(\.presentationMode) var presentationMode
    
    // State variable for holding the note being edited or displayed.
    @State var note: Note
    
    // The notes manager responsible for handling note CRUD operations.
    @ObservedObject var notesManager: NotesManager
    
    // AppStorage properties to persist user preferences for dark mode and theme selection.
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    
    // Boolean to indicate whether the note is a new note or an existing one.
    var isNewNote: Bool
    
    // State variables for controlling the display of the share sheet and delete confirmation alert.
    @State private var showingShareSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        // Dynamic colors and styles based on theme and dark mode settings.
        let theme = selectedTheme.theme
        let backgroundColor = isDarkMode ? Color(UIColor.systemBackground) : theme.lightBackgroundColor
        let textColor = isDarkMode ? Color.white : theme.lightTextColor
        let editorBackgroundColor = isDarkMode ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemGray6)

        VStack {
            // Form containing the note title and content fields.
            Form {
                // Text field for editing the note's title.
                TextField("Title", text: $note.title)
                    .foregroundColor(textColor)
                    .padding(10)
                    .background(editorBackgroundColor)
                    .cornerRadius(10)
                
                // Text editor for editing the note's content.
                TextEditor(text: $note.content)
                    .foregroundColor(textColor)
                    .padding(10)
                    .background(editorBackgroundColor)
                    .cornerRadius(10)
                    .frame(minHeight: 200)
                    .padding(.top, 5)
            }
            .scrollContentBackground(.hidden)  // Hide the default background to use custom colors.
            .background(backgroundColor)
            Spacer()
        }
        // Set the navigation bar title to the note's title or "New Note" if the title is empty.
        .navigationBarTitle(Text(note.title.isEmpty ? "New Note" : note.title), displayMode: .inline)
        // Navigation bar items for canceling, saving, deleting, and sharing the note.
        .navigationBarItems(
            leading: isNewNote ? Button("Cancel") { cancelNote() } : nil,  // Cancel button for new notes only.
            trailing: HStack(spacing: 20) {
                if !isNewNote {  // Only show delete and share options for existing notes.
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
                if isNewNote {  // Save button for new notes.
                    Button("Save") {
                        saveNote()
                    }
                    .foregroundColor(.blue)
                }
            }
        )
        .background(backgroundColor.edgesIgnoringSafeArea(.all))  // Set the background color.
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Adapt to dark or light mode.
        // Automatically save the note whenever the title or content changes.
        .onChange(of: note.title) { _ in
            if !isNewNote {
                saveNote()
            }
        }
        .onChange(of: note.content) { _ in
            if !isNewNote {
                saveNote()
            }
        }
        // Display the share sheet when triggered.
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [note.title, note.content])
        }
        // Display the delete confirmation alert when triggered.
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Note"),
                message: Text("Are you sure you want to delete this note?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteNote()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Saves the note to the notes manager. If it's a new note, it adds it to the manager and dismisses the view.
    private func saveNote() {
        if note.title.isEmpty {
            note.title = "Untitled Note"  // Ensure that untitled notes are saved with a default title.
        }
        if notesManager.notes.contains(where: { $0.id == note.id }) {
            notesManager.update(note)  // Update the existing note.
        } else {
            notesManager.add(note)  // Add the new note.
        }
        if isNewNote {
            presentationMode.wrappedValue.dismiss()  // Dismiss the view if it's a new note.
        }
    }

    // Cancels the note creation and dismisses the view.
    private func cancelNote() {
        presentationMode.wrappedValue.dismiss()
    }

    // Deletes the note from the notes manager and dismisses the view.
    private func deleteNote() {
        notesManager.delete(note)
        presentationMode.wrappedValue.dismiss()
    }
}

// A wrapper for UIKit's UIActivityViewController, which presents the share sheet to share the note's content.
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]  // The items to share, such as the note's title and content.
    var applicationActivities: [UIActivity]? = nil  // Custom activities, defaults to nil.

    // Creates the UIActivityViewController.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    // No update logic required for this view controller.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
