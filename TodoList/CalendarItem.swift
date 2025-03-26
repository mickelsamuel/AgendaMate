import Foundation
import EventKit

// A unified model that represents either a task or a calendar event. This enum is used to handle both
// tasks and events within the same list or collection while providing a common interface for accessing their properties.
enum CalendarItem: Identifiable {
    // The two cases of CalendarItem: either a `Task` or an `EKEvent` (from EventKit).
    case task(Task)
    case event(EKEvent)
    
    // Unique identifier for the CalendarItem, which is the task's UUID or the event's eventIdentifier.
    var id: String {
        switch self {
        case .task(let task):
            return task.id.uuidString  // Task's UUID as a string.
        case .event(let event):
            return event.eventIdentifier  // Event's unique identifier.
        }
    }
    
    // The start date of the CalendarItem. If it's a task, the due date is used; if not set, a distant past date is used as a fallback.
    var startDate: Date {
        switch self {
        case .task(let task):
            return task.dueDate ?? Date.distantPast  // Use task's due date or a default distant past date.
        case .event(let event):
            return event.startDate  // Event's start date.
        }
    }
    
    // The title of the CalendarItem. If it's a task, the task's title is used; if it's an event, the event's title is used.
    var title: String {
        switch self {
        case .task(let task):
            return task.title  // Task's title.
        case .event(let event):
            return event.title ?? ""  // Event's title or an empty string if the title is nil.
        }
    }
}
