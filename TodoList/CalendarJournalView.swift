import SwiftUI

// A view that allows users to select a date from a graphical DatePicker and navigate to a journal entry for the selected date.
// The view also adjusts to light or dark mode, as well as a customizable theme color and font size.
struct CalendarJournalView: View {
    // State variable to track the currently selected date.
    @State private var selectedDate = Date()
    
    // The color theme passed to the view to customize the appearance.
    var themeColor: Color
    
    // AppStorage properties to persist user preferences for dark mode and font size.
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0

    var body: some View {
        // Determine background and text colors based on dark mode setting.
        let backgroundColor = isDarkMode ? Color.black : Color.white
        let textColor = isDarkMode ? Color.white : Color.black

        VStack {
            // Title of the journal view with dynamic font size and custom styling.
            Text("Journal")
                .font(.system(size: selectedFontSize * 2.1, weight: .bold))
                .foregroundColor(textColor)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            // DatePicker allowing the user to select a date. The selected date is stored in `selectedDate`.
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())  // Graphical style for date selection.
                .accentColor(themeColor)  // Apply the theme color to the DatePicker's accent.
                .padding(.horizontal)

            Spacer(minLength: 10)

            // NavigationLink to navigate to the JournalEntryView for the selected date.
            NavigationLink(destination: JournalEntryView(date: selectedDate, themeColor: themeColor)) {
                Text("Open Journal")
                    .font(.system(size: selectedFontSize))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeColor)  // Background color set to the theme color.
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 150)

            Spacer(minLength: 10)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Ensure the view adapts to dark or light mode.
        .background(backgroundColor.edgesIgnoringSafeArea(.all))  // Set the background color based on mode.
        .font(.system(size: selectedFontSize))  // Apply user-defined font size.
    }
}

// A view that displays a journal entry for the selected date. The journal entry can be edited and is automatically saved when changes occur.
struct JournalEntryView: View {
    // The date for which the journal entry is being viewed or edited.
    var date: Date
    
    // The color theme for the view.
    var themeColor: Color
    
    // State variable to hold the text content of the journal entry.
    @State private var journalText = ""
    
    // AppStorage properties to persist user preferences for dark mode and font size.
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0

    var body: some View {
        // Determine text color based on dark mode setting.
        let textColor = isDarkMode ? Color.white : Color.black

        VStack(alignment: .leading) {
            // Title of the journal entry view with dynamic font size and custom styling.
            Text("Journal Entry")
                .font(.system(size: selectedFontSize * 2, weight: .bold))  // Larger font size and bold weight.
                .foregroundColor(textColor)
                .padding(.top, 30)
                .padding(.leading, 20)  // Align to the left.
                .frame(maxWidth: .infinity, alignment: .leading)

            // TextEditor for editing the journal entry text.
            TextEditor(text: $journalText)
                .foregroundColor(textColor)
                .font(.system(size: selectedFontSize))
                .padding()
                .background(Color.clear)

            Spacer()
        }
        .onAppear {
            loadJournalEntry()  // Load the journal entry when the view appears.
        }
        .onDisappear {
            saveJournalEntry()  // Automatically save the journal entry when the view disappears.
        }
        .onChange(of: journalText) { _ in
            saveJournalEntry()  // Save the journal entry whenever the text changes.
        }
        .accentColor(themeColor)  // Apply the theme color to interactive elements.
        .background(isDarkMode ? Color.black : Color.white)  // Set background color based on dark mode.
    }

    // Saves the current journal entry to UserDefaults with a key derived from the selected date.
    private func saveJournalEntry() {
        UserDefaults.standard.set(journalText, forKey: journalKey(for: date))
    }

    // Loads the journal entry for the selected date from UserDefaults.
    private func loadJournalEntry() {
        journalText = UserDefaults.standard.string(forKey: journalKey(for: date)) ?? ""
    }

    // Generates a unique key for storing the journal entry in UserDefaults, based on the date.
    private func journalKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "journal-\(formatter.string(from: date))"
    }
}
