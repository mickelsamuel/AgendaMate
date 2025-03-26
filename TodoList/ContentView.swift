import SwiftUI

// The main content view for the ToDoList app, which includes navigation between different sections of the app
// (To-Do List, Calendar, Journal, Notes) and handles the state management for various app settings and features.
struct ContentView: View {
    // A shared instance of TaskManager to manage and track tasks throughout the app.
    @StateObject private var taskManager = TaskManager.shared
    
    // State properties to manage search text and selected categories within the To-Do List view.
    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil
    
    // AppStorage properties to persist user preferences for dark mode, theme, font size, and visibility of app sections.
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0
    @AppStorage("showNotes") private var showNotes: Bool = true
    @AppStorage("showTodoList") private var showTodoList: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true
    @AppStorage("showJournal") private var showJournal: Bool = true
    
    // Environment property to access the current color scheme (dark/light mode).
    @Environment(\.colorScheme) var colorScheme
    
    // State properties for managing the currently selected tab, and displaying task addition or settings views.
    @State private var selectedTab = 1
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var selectedTimeRange: Int = 7  // Controls the time range for displaying completed tasks.

    var body: some View {
        // Define colors based on the current theme and dark mode settings.
        let theme = selectedTheme.theme
        let primaryColor = isDarkMode ? theme.darkPrimaryColor : theme.lightPrimaryColor
        let secondaryColor = isDarkMode ? theme.darkSecondaryColor : theme.lightSecondaryColor
        let backgroundColor = isDarkMode ? Color.black : theme.lightBackgroundColor
        let textColor = isDarkMode ? theme.darkTextColor : theme.lightTextColor
        let contrastColor = theme.contrastColor

        // TabView allows navigation between different sections (To-Do, Calendar, Journal, Notes).
        return TabView(selection: $selectedTab) {
            // To-Do List tab
            if showTodoList {
                NavigationView {
                    VStack {
                        // Task filtering and sorting section.
                        VStack {
                            // Category picker for filtering tasks by category.
                            Picker("Category", selection: $selectedCategory) {
                                Text("All").tag(Category?.none)
                                ForEach(Category.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category as Category?)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()

                            // Sort picker for sorting tasks by various criteria (e.g., due date, priority).
                            Picker("Sort By", selection: $taskManager.sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }
                        .background(primaryColor)
                        .foregroundColor(textColor)

                        // Task list and search bar.
                        List {
                            SearchBar(searchText: $searchText, backgroundColor: secondaryColor, textColor: textColor, isDarkMode: isDarkMode)
                                .listRowBackground(backgroundColor)

                            taskSection(backgroundColor: backgroundColor, textColor: textColor)
                                .listRowBackground(backgroundColor)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .background(backgroundColor)

                        // Completed tasks section for showing tasks completed in a selected time range.
                        if !completedTasks(for: selectedTimeRange).isEmpty {
                            VStack(alignment: .leading) {
                                Text("Completed Tasks")
                                    .font(.body)
                                    .foregroundColor(textColor)
                                    .padding(.leading)
                                
                                // Picker to select the time range for completed tasks.
                                Picker("Select Time Range", selection: $selectedTimeRange) {
                                    Text("3 Days").tag(3)
                                    Text("7 Days").tag(7)
                                    Text("14 Days").tag(14)
                                    Text("30 Days").tag(30)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                .foregroundColor(textColor)

                                // Display completed tasks in a scrollable list.
                                ScrollView {
                                    LazyVStack {
                                        ForEach(completedTasks(for: selectedTimeRange)) { task in
                                            HStack {
                                                Text(task.title)
                                                    .foregroundColor(textColor)
                                                Spacer()
                                                if let completedDate = task.completedDate {
                                                    Text(formattedDate(completedDate))
                                                        .foregroundColor(textColor)
                                                } else {
                                                    Text("No Date")
                                                        .foregroundColor(textColor)
                                                }
                                            }
                                            .padding(.vertical, 5)
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                            }
                            .padding()
                            .background(backgroundColor)
                            .foregroundColor(textColor)
                        }
                    }
                    .navigationTitle("To-Do List")
                    // Navigation bar buttons for adding tasks or opening settings.
                    .navigationBarItems(trailing: HStack {
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(contrastColor)
                        }
                        if !showCalendar {
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(contrastColor)
                            }
                            .sheet(isPresented: $showingSettings) {
                                SettingsView()
                            }
                        }
                    })
                    .sheet(isPresented: $showingAddTask) {
                        AddTaskView(taskManager: taskManager)
                            .environment(\.colorScheme, isDarkMode ? .dark : .light)
                    }
                }
                .tabItem {
                    Image(systemName: "checklist")
                    Text("To-Do")
                }
                .tag(0)
            }

            // Calendar tab
            if showCalendar {
                NavigationView {
                    CalendarView()
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)
            }

            // Journal tab
            if showJournal {
                NavigationView {
                    CalendarJournalView(themeColor: primaryColor)
                }
                .tabItem {
                    Image(systemName: "book")
                    Text("Journal")
                }
                .tag(2)
            }

            // Notes tab
            if showNotes {
                NavigationView {
                    NotesView()
                        .navigationBarItems(trailing: HStack {
                            if !showTodoList && !showCalendar {
                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gearshape")
                                        .foregroundColor(contrastColor)
                                }
                                .sheet(isPresented: $showingSettings) {
                                    SettingsView()
                                }
                            }
                        })
                }
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
                .tag(3)
            }
        }
        // Apply app-wide settings for color scheme, accent color, font size, and background.
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .accentColor(primaryColor)
        .font(.system(size: selectedFontSize))
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onChange(of: isDarkMode) { newValue in
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
        }
    }

    // Generates the section of tasks filtered by search text and selected category.
    private func taskSection(backgroundColor: Color, textColor: Color) -> some View {
        Section(header: Text("Tasks").foregroundColor(textColor)) {
            ForEach(filteredTasks) { task in
                TaskRow(task: task, backgroundColor: backgroundColor, textColor: textColor)
            }
            .onDelete(perform: deleteTasks)
        }
    }

    // Filters tasks based on search text and selected category.
    var filteredTasks: [Task] {
        taskManager.sortedTasks().filter { task in
            (selectedCategory == nil || task.category == selectedCategory) &&
            (searchText.isEmpty || task.title.lowercased().contains(searchText.lowercased()))
        }
    }

    // Deletes tasks based on the provided index set.
    func deleteTasks(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = taskManager.tasks[index]
            taskManager.deleteTask(task)
        }
    }

    // Returns a list of tasks completed within the specified time range (in days).
    private func completedTasks(for days: Int) -> [Task] {
        let calendar = Calendar.current
        let today = Date()
        return taskManager.tasks.filter { task in
            if let completedDate = task.completedDate {
                let daysBetween = calendar.dateComponents([.day], from: completedDate, to: today).day ?? 0
                return task.isCompleted && daysBetween <= days
            }
            return false
        }
    }

    // Formats a date as a short string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: ContentView {
        ContentView()
    }
}
