import SwiftUI

struct SettingsView: View {
    // AppStorage properties for persisting user settings across app launches.
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("showTodoList") private var showTodoList: Bool = true
    @AppStorage("showJournal") private var showJournal: Bool = true
    @AppStorage("showNotes") private var showNotes: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true

    // Environment variables to access system-level properties and control the view presentation.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    // State variable for handling an edge case where user tries to hide all sections.
    @State private var showingValidationError = false

    var body: some View {
        NavigationView {
            Form {
                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    HStack {
                        Text("Font Size")
                        Slider(value: $selectedFontSize, in: 12...24, step: 1)
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                // Visibility Section
                Section(header: Text("Visibility")) {
                    Toggle("Show To-Do List", isOn: Binding(
                        get: { showTodoList },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showTodoList") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Journal", isOn: Binding(
                        get: { showJournal },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showJournal") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Notes", isOn: Binding(
                        get: { showNotes },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showNotes") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Calendar", isOn: Binding(
                        get: { showCalendar },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showCalendar") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .foregroundColor(colorScheme == .dark ? .white : .blue)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    private func handleToggleChange(newValue: Bool, key: String) {
        let totalOn = [showTodoList, showJournal, showNotes, showCalendar].filter { $0 }.count

        // Prevent all sections from being switched off at once.
        if totalOn == 1 && !newValue {
            showingValidationError = true
        } else {
            switch key {
            case "showTodoList": showTodoList = newValue
            case "showJournal": showJournal = newValue
            case "showNotes": showNotes = newValue
            case "showCalendar": showCalendar = newValue
            default: break
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
