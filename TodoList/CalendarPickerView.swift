import SwiftUI

// A custom calendar picker that allows users to select dates within a specific month.
// The view displays the days of the selected month in a grid and highlights the selected date.
struct CalendarPickerView: View {
    // Binding to track the selected date.
    @Binding var selectedDate: Date
    
    // The theme color for the selected date's background.
    var themeColor: Color
    
    // The calendar used for date calculations, set to the current user's calendar.
    private let calendar = Calendar.current
    
    // Defines a grid layout with 7 flexible columns, representing the days of the week.
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack {
            // Header with navigation buttons for changing months and displaying the current month and year.
            HStack {
                // Button to go to the previous month.
                Button(action: {
                    selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                // Display the current month and year.
                Text(monthAndYearString(for: selectedDate))
                    .font(.headline)
                Spacer()
                // Button to go to the next month.
                Button(action: {
                    selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // A grid of weekdays followed by the days of the current month.
            LazyVGrid(columns: columns, spacing: 10) {
                // Display the weekday symbols at the top of the grid (e.g., Sun, Mon, Tue).
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                }

                // Display the days of the selected month.
                ForEach(generateDaysInMonth(for: selectedDate), id: \.self) { day in
                    // Display the day of the month.
                    Text("\(calendar.component(.day, from: day))")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(8)
                        // Highlight the selected day with the theme color.
                        .background(isSameDay(date1: selectedDate, date2: day) ? themeColor : Color.clear)
                        .cornerRadius(10)
                        // Update the selected date when a day is tapped.
                        .onTapGesture {
                            selectedDate = day
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    // An array of short weekday symbols (e.g., Sun, Mon, Tue) for the calendar header.
    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        return formatter.shortWeekdaySymbols
    }

    // Generates a string that displays the current month and year for the selected date.
    private func monthAndYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // Generates an array of dates representing all the days within the selected month.
    private func generateDaysInMonth(for date: Date) -> [Date] {
        // Get the start and end dates of the selected month.
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        
        var days: [Date] = []
        var currentDate = monthInterval.start

        // Loop through the days in the month and add them to the array.
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }

    // Checks if two dates fall on the same day.
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}
