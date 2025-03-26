import SwiftUI
import MapKit
import EventKit

// A view that integrates a calendar, task and event management, and weather information. Users can view and manage tasks and events,
// add new events, and view the weather forecast based on their current location.
struct CalendarView: View {
    // Observed state objects for task management and location services.
    @StateObject private var taskManager = TaskManager.shared
    @StateObject private var locationManager = LocationManager()
    
    // State variables to track the selected date, whether the add event view is being shown, and theme settings.
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingSettings = false
    
    // AppStorage properties for theme and dark mode settings.
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Number of days to display in the event and task list.
    @State private var daysToDisplay: Int = 3
    
    // State to trigger refreshes when tasks/events change.
    @State private var refreshID = UUID()

    var body: some View {
        // Set theme colors based on dark mode and selected theme.
        let theme = selectedTheme.theme
        let primaryColor = isDarkMode ? theme.darkPrimaryColor : theme.lightPrimaryColor

        VStack(spacing: 0) {
            // Top toolbar with settings and add event buttons.
            HStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))  // Increased size for better visibility.
                        .foregroundColor(primaryColor)
                        .padding(.leading, 20)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }

                Spacer()

                Button(action: { showingAddEvent = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))  // Increased size for better visibility.
                        .foregroundColor(primaryColor)
                        .padding(.trailing, 20)
                }
                .sheet(isPresented: $showingAddEvent, onDismiss: {
                    // Refresh the view after adding a new event.
                    refreshID = UUID()  // Trigger refresh by updating a unique ID.
                }) {
                    AddEventView()
                }
            }
            .padding(.top, 10)  // Ensure buttons are below the status bar.

            // Title for the calendar section.
            Text("Calendar")
                .font(.largeTitle)
                .bold()
                .padding(.top, 25)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            
            // Calendar picker for selecting dates.
            CalendarPickerView(selectedDate: $selectedDate, themeColor: primaryColor)
                .padding(.horizontal, 20)
                .padding(.top, 35)

            // Weather forecast for the selected location, displayed when data is available.
            if let weather = locationManager.weatherData {
                let dayWeather = weather.forecast.forecastday.first?.day
                HStack {
                    if let iconUrl = URL(string: "https:\(dayWeather?.condition.icon ?? "")") {
                        AsyncImageLoader(url: iconUrl)
                            .frame(width: 30, height: 30)
                    }
                    VStack(alignment: .leading) {
                        if let maxtemp = dayWeather?.maxtemp_c, let mintemp = dayWeather?.mintemp_c {
                            let localizedMaxTemp = localizedNumber(maxtemp)
                            let localizedMinTemp = localizedNumber(mintemp)
                            Text("Temperature: \(localizedMaxTemp)°C - \(localizedMinTemp)°C")
                        }
                        Text("Weather: \(dayWeather?.condition.text ?? "N/A")")
                        Text("City: \(weather.location.name)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .padding(.top, 15)
            } else {
                // Show loading text while weather data is being fetched.
                Text("Fetching weather data...")
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
            }

            // Days picker for filtering tasks and events by time frame (e.g., next 3 days, 1 week).
            HStack {
                Text("Next")
                Picker("Days", selection: $daysToDisplay) {
                    ForEach(daysPickerOptions(), id: \.tag) { option in
                        Text(option.text).tag(option.tag)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // List of tasks and events within the selected time frame.
            List {
                Section(header: Text("Next \(localizedNumber(Double(daysToDisplay))) Days")) {
                    ForEach(tasksAndEventsForNextDays(), id: \.id) { item in
                        switch item {
                        case .task(let task):
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                HStack {
                                    Text(task.title)
                                    Spacer()
                                    Text(formattedDate(date: task.dueDate))
                                        .foregroundColor(.gray)
                                }
                            }
                        case .event(let event):
                            NavigationLink(destination: EventDetailView(event: event)) {
                                HStack {
                                    Text(event.title ?? "No Title")
                                    Spacer()
                                    Text(formattedDate(date: event.startDate))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }

            .listStyle(InsetGroupedListStyle())
            .padding(.top, 5)
            .id(refreshID)  // Use the unique ID to force a refresh when this view changes.
        }
        .onAppear {
            // Request location and weather data when the view appears.
            locationManager.requestPermission()
            locationManager.weatherService = WeatherService()
        }
        .onChange(of: selectedDate) { _ in
            // Trigger a refresh when the selected date changes.
            refreshID = UUID()
        }
    }

    // Provides options for the number of days to display in the tasks and events list.
    private func daysPickerOptions() -> [(text: String, tag: Int)] {
        return [
            (text: "3 Days", tag: 3),
            (text: "1 Week", tag: 7),
            (text: "2 Weeks", tag: 14),
            (text: "1 Month", tag: 30)
        ]
    }

    // Returns a combined list of tasks and events for the selected number of days.
    private func tasksAndEventsForNextDays() -> [CalendarItem] {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        let endDate = calendar.date(byAdding: .day, value: daysToDisplay, to: startDate)!
        
        // Fetch tasks and events within the selected date range.
        let tasks = taskManager.tasks.filter { task in
            task.dueDate.map { (startDate...endDate).contains($0) } ?? false
        }.map(CalendarItem.task)
        let events = CalendarManager.shared.fetchEvents(from: startDate, to: endDate).map(CalendarItem.event)
        
        // Sort tasks and events by start date.
        return (tasks + events).sorted(by: { $0.startDate < $1.startDate })
    }

    // Formats a date into a user-friendly string.
    private func formattedDate(date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Localizes a number to be displayed with a maximum of 1 decimal place.
    private func localizedNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
