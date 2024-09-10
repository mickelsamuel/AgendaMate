import SwiftUI

// Enumeration for the various sort options for notes.
// Conforms to `CaseIterable` to enable iteration over all cases and `Identifiable` to allow usage in SwiftUI pickers.
enum NotesSortOption: String, CaseIterable, Identifiable {
    case title = "Title"      // Sort notes alphabetically by title.
    case date = "Date"        // Sort notes by their creation or modification date.
    case custom = "Custom"    // Custom order defined by the user.

    var id: String { self.rawValue }  // `id` is required by `Identifiable` to uniquely identify each case.
}

// The main view that displays and manages the user's notes.
// It includes sorting, searching, and basic CRUD operations, as well as integration with dark mode and customizable themes.
struct NotesView: View {
    // The notes manager that handles note data.
    @StateObject private var notesManager = NotesManager()

    // State variables for tracking the display of the add note view and sorting/searching.
    @State private var showingAddNoteView = false
    @State private var sortOption: NotesSortOption = .title
    @State private var searchText = ""

    // AppStorage properties to persist user preferences for dark mode, theme, and font size.
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0

    var body: some View {
        // Set up the theme colors based on the selected theme and dark mode settings.
        let theme = selectedTheme.theme
        let primaryColor = isDarkMode ? theme.darkPrimaryColor : theme.lightPrimaryColor
        let secondaryColor = isDarkMode ? theme.darkSecondaryColor : theme.lightSecondaryColor
        let backgroundColor = isDarkMode ? Color.black : theme.lightBackgroundColor
        let textColor = isDarkMode ? theme.darkTextColor : theme.lightTextColor
        let contrastColor = theme.contrastColor

        // The main view structure for the Notes view, which includes sorting, searching, and displaying notes.
        NavigationView {
            VStack {
                // A picker to allow the user to select how to sort notes.
                VStack {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(NotesSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                .background(primaryColor)
                .foregroundColor(textColor)

                // A search bar for filtering notes by title.
                SearchBar(searchText: $searchText, backgroundColor: secondaryColor, textColor: textColor, isDarkMode: isDarkMode)
                    .padding([.leading, .trailing])

                // The list of notes, filtered by the search text and sorted by the selected sort option.
                List {
                    ForEach(notesManager.sortedNotes(by: sortOption).filter { note in
                        searchText.isEmpty || note.title.lowercased().contains(searchText.lowercased())
                    }) { note in
                        // NavigationLink to the note's detail view when a note is selected.
                        NavigationLink(destination: NoteDetailView(note: note, notesManager: notesManager, isNewNote: false)) {
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.dateFormatted())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    // Enable deleting notes and moving notes when the custom sort option is selected.
                    .onDelete(perform: deleteNotes)
                    .onMove(perform: moveNotes)
                }
                .listStyle(InsetGroupedListStyle())
                .background(backgroundColor)
            }
            .navigationTitle("Notes")
            // Navigation bar items for adding and editing notes.
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                showingAddNoteView = true  // Show the add note view when the "+" button is tapped.
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))  // The "+" button size and styling.
                    .foregroundColor(contrastColor)
                    .padding(.trailing, 0)
                    .padding(.top, 0)
            })
            // A sheet to present the add note view.
            .sheet(isPresented: $showingAddNoteView) {
                NavigationView {
                    NoteDetailView(note: Note(), notesManager: notesManager, isNewNote: true)
                        .environment(\.colorScheme, isDarkMode ? .dark : .light)  // Set color scheme for the add note view.
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Apply the preferred color scheme (dark or light mode).
        .accentColor(primaryColor)  // Set the accent color based on the theme.
        .font(.system(size: selectedFontSize))  // Set the font size based on the user's preference.
        .background(backgroundColor.edgesIgnoringSafeArea(.all))  // Set the background color and make it cover the entire screen.
    }

    // Delete the notes at the specified offsets.
    private func deleteNotes(at offsets: IndexSet) {
        offsets.forEach { index in
            let note = notesManager.sortedNotes(by: sortOption)[index]
            notesManager.delete(note)
        }
    }

    // Move notes when the custom sort option is selected.
    private func moveNotes(from source: IndexSet, to destination: Int) {
        if sortOption == .custom {
            notesManager.moveNotes(from: source, to: destination)
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: NotesView {
        NotesView()  // Preview of the NotesView.
    }
}
