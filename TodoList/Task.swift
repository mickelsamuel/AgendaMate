import Foundation
import SwiftUI
import UIKit

// An enumeration representing the priority levels of a task (low, medium, high).
enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// An enumeration representing the different categories a task can belong to (work, personal, urgent, other).
enum Category: String, Codable, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case urgent = "Urgent"
    case other = "Other"
}

// A class representing a task, conforming to Identifiable, Codable, and ObservableObject.
// It contains various properties related to the task, including title, due date, priority, subtasks, comments, etc.
class Task: Identifiable, Codable, ObservableObject {
    @Published var id: UUID  // Unique identifier for the task.
    @Published var title: String  // The title of the task.
    @Published var isCompleted: Bool  // Boolean to indicate if the task is completed.
    @Published var dueDate: Date?  // Optional due date for the task.
    @Published var completedDate: Date?  // Optional date when the task was completed.
    @Published var priority: Priority  // The priority level of the task.
    @Published var category: Category  // The category of the task.
    @Published var reminderDate: Date?  // Optional reminder date for the task.
    @Published var recurring: Bool  // Boolean to indicate if the task recurs.
    @Published var recurrenceFrequency: RecurrenceFrequency  // The frequency of recurrence (e.g., daily, weekly).
    @Published var subtasks: [Subtask]  // An array of subtasks associated with this task.
    @Published var comments: [Comment]  // An array of comments attached to this task.
    @Published var color: Color  // The color associated with the task (e.g., for UI purposes).
    @Published var attachedImage: UIImage?  // An optional image attached to the task.
    @Published var tags: [String] = []  // An array of tags to help categorize the task.

    // Initializer for creating a new task with default and optional parameters.
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date? = nil, completedDate: Date? = nil, priority: Priority = .medium, category: Category = .other, reminderDate: Date? = nil, recurring: Bool = false, recurrenceFrequency: RecurrenceFrequency = .none, subtasks: [Subtask] = [], comments: [Comment] = [], color: Color = .blue, attachedImage: UIImage? = nil, tags: [String] = []) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.completedDate = completedDate
        self.priority = priority
        self.category = category
        self.reminderDate = reminderDate
        self.recurring = recurring
        self.recurrenceFrequency = recurrenceFrequency
        self.subtasks = subtasks
        self.comments = comments
        self.color = color
        self.attachedImage = attachedImage
        self.tags = tags
    }

    // Enum for mapping properties to keys when encoding/decoding to/from Codable format.
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, dueDate, priority, category, reminderDate, recurring, recurrenceFrequency, subtasks, comments, color, attachedImage, tags
    }

    // Decoder for loading a task from stored data (Codable conformance).
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try container.decode(Priority.self, forKey: .priority)
        category = try container.decode(Category.self, forKey: .category)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        recurring = try container.decode(Bool.self, forKey: .recurring)
        recurrenceFrequency = try container.decode(RecurrenceFrequency.self, forKey: .recurrenceFrequency)
        subtasks = try container.decode([Subtask].self, forKey: .subtasks)
        comments = try container.decode([Comment].self, forKey: .comments)

        // Decode the task color as a Data object and convert it to UIColor.
        let colorData = try container.decode(Data.self, forKey: .color)
        color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)?.color ?? .blue
        
        // Decode the attached image as Data if present.
        if let imageData = try container.decodeIfPresent(Data.self, forKey: .attachedImage) {
            attachedImage = UIImage(data: imageData)
        } else {
            attachedImage = nil
        }
        
        tags = try container.decode([String].self, forKey: .tags)
    }

    // Encoder for saving a task to a storable format (Codable conformance).
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(recurring, forKey: .recurring)
        try container.encode(recurrenceFrequency, forKey: .recurrenceFrequency)
        try container.encode(subtasks, forKey: .subtasks)
        try container.encode(comments, forKey: .comments)

        // Encode the task color as a Data object.
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
        
        // Encode the attached image as Data if present.
        if let attachedImage = attachedImage {
            let imageData = attachedImage.pngData()
            try container.encodeIfPresent(imageData, forKey: .attachedImage)
        }
        
        try container.encode(tags, forKey: .tags)
    }
}

// A struct representing a subtask, conforming to Identifiable and Codable.
struct Subtask: Identifiable, Codable {
    var id: UUID  // Unique identifier for the subtask.
    var title: String  // Title of the subtask.
    var isCompleted: Bool  // Boolean to indicate if the subtask is completed.

    // Initializer for creating a new subtask.
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// A struct representing a comment, conforming to Identifiable and Codable.
// Used for storing comments attached to tasks.
struct Comment: Identifiable, Codable {
    var id: UUID  // Unique identifier for the comment.
    var text: String  // Text content of the comment.
    var date: Date  // Date the comment was created.

    // Initializer for creating a new comment.
    init(id: UUID = UUID(), text: String, date: Date = Date()) {
        self.id = id
        self.text = text
        self.date = date
    }
}

// Extension to convert a UIColor to a SwiftUI Color.
extension UIColor {
    var color: Color {
        return Color(self)
    }
}
