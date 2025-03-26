import Foundation
import EventKit

// A class that manages interactions with the user's calendar using EventKit.
// It handles requesting access to the calendar, adding events, fetching events, and exporting events to CSV format.
class CalendarManager {
    // Shared singleton instance of CalendarManager for global access.
    static let shared = CalendarManager()
    
    // Event store for accessing and managing calendar events.
    private let eventStore = EKEventStore()

    // Requests access to the user's calendar. The result is returned through the completion handler.
    // If access is granted, `granted` is true, otherwise, an error is provided.
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            // Ensure that the completion handler is executed on the main thread.
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }

    // Saves an existing event to the user's calendar, updating its details.
    // The event object is passed, and the operation's success is returned through the completion handler.
    func saveEvent(event: EKEvent, completion: @escaping (Bool, Error?) -> Void) {
        // Request access to the calendar before attempting to save the event.
        requestAccess { granted, error in
            guard granted, error == nil else {
                completion(false, error)  // If access is denied, return the error through the completion handler.
                return
            }

            // Try saving the updated event and handle any errors.
            do {
                try self.eventStore.save(event, span: .thisEvent)
                completion(true, nil)  // Successfully saved the event.
            } catch let saveError {
                completion(false, saveError)  // Failed to save the event, pass the error through the completion handler.
            }
        }
    }
    
    // Function to delete an event from the user's calendar.
    func deleteEvent(event: EKEvent, completion: @escaping (Bool, Error?) -> Void) {
        requestAccess { granted, error in
            guard granted, error == nil else {
                completion(false, error)
                return
            }
            
            do {
                // Attempt to delete the event.
                try self.eventStore.remove(event, span: .thisEvent)
                completion(true, nil)
            } catch let deleteError {
                completion(false, deleteError)
            }
        }
    }

    // Adds a new event to the user's calendar. The event's title, start date, end date, location, and notes
    // are passed as parameters, and the result of the operation is returned through the completion handler.
    func addEvent(title: String, startDate: Date, endDate: Date, location: String?, notes: String?, completion: @escaping (Bool, Error?) -> Void) {
        // Request access to the calendar before attempting to add the event.
        requestAccess { granted, error in
            guard granted, error == nil else {
                completion(false, error)  // If access is denied, return the error through the completion handler.
                return
            }

            // Create a new event and configure its properties.
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            event.location = location
            event.notes = notes

            // Try saving the event and handle any errors.
            do {
                try self.eventStore.save(event, span: .thisEvent)
                completion(true, nil)  // Successfully saved the event.
            } catch let saveError {
                completion(false, saveError)  // Failed to save the event, pass the error through the completion handler.
            }
        }
    }

    // Fetches events between the given start date and end date from the user's calendar.
    // Returns an array of matching events.
    func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
        // Create a predicate to query events within the specified date range.
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        // Fetch and return events matching the predicate.
        return eventStore.events(matching: predicate)
    }

    // Exports the user's upcoming events (within the next year) to a CSV format string.
    // The CSV contains columns for event title, start date, end date, and notes.
    func exportEvents() -> String {
        // CSV header row.
        var csvString = "Title,Start Date,End Date,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        // Define the date range for exporting events (from now to one year ahead).
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? Date()

        // Fetch events within the defined date range.
        let events = fetchEvents(from: startDate, to: endDate)

        // Append event data to the CSV string.
        for event in events {
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)
            csvString.append("\(event.title ?? "No Title"),\(startDateString),\(endDateString),\(event.notes ?? "")\n")
        }
        
        return csvString  // Return the constructed CSV string.
    }
}
