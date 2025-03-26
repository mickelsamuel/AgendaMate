import SwiftUI
import CoreData

// The TaskManager class is responsible for managing the tasks and journal entries.
// It includes functionality for adding, updating, deleting, sorting, and exporting/importing tasks,
// as well as tracking task completion and managing custom task orders. This class conforms to ObservableObject,
// enabling SwiftUI views to observe changes to task data.

class TaskManager: ObservableObject {
    // A shared singleton instance of the TaskManager for global access throughout the app.
    static let shared = TaskManager()
    
    // Published properties to allow SwiftUI views to reactively update when tasks or sorting options change.
    @Published var tasks: [Task] = []  // List of all tasks.
    @Published var journalEntries: [JournalEntry] = []  // List of all journal entries.
    @Published var sortOption: SortOption = .title  // Current sorting option for tasks.
    @Published var customOrder: [UUID] = []  // Custom order of tasks, stored as a list of task IDs.
    
    // Private initializer ensures that only one instance of TaskManager exists (singleton pattern).
    private init() {
        loadTasks()  // Load tasks from persistent storage when the manager is initialized.
    }

    // Adds a new task to the list and saves tasks to persistent storage.
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()  // Persist changes to UserDefaults.
    }

    // Updates an existing task in the list and saves changes.
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }

    // Deletes a task from the list and saves changes.
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    // Toggles the completion status of a task and saves the changes.
    func toggleComplete(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }

    // Saves the tasks and custom order to UserDefaults using JSON encoding.
    private func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: "tasks")
        }
        if let encodedOrder = try? JSONEncoder().encode(customOrder) {
            UserDefaults.standard.set(encodedOrder, forKey: "customOrder")
        }
    }

    // Loads tasks and custom order from UserDefaults and decodes them using JSON decoding.
    private func loadTasks() {
        let decoder = JSONDecoder()
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? decoder.decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
        }
        if let savedOrder = UserDefaults.standard.data(forKey: "customOrder"),
           let decodedOrder = try? decoder.decode([UUID].self, from: savedOrder) {
            customOrder = decodedOrder
        }
    }

    // Returns the number of tasks completed within the specified number of days.
    func tasksCompleted(in days: Int) -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return tasks.filter { $0.isCompleted && ($0.dueDate ?? Date()) >= cutoffDate }.count
    }

    // Calculates the average time between the reminder date and due date for completed tasks.
    var averageCompletionTime: TimeInterval {
        let completedTasks = tasks.filter { $0.isCompleted }
        guard !completedTasks.isEmpty else { return 0 }

        let totalCompletionTime = completedTasks.reduce(0.0) { total, task in
            total + (task.dueDate?.timeIntervalSince(task.reminderDate ?? Date()) ?? 0)
        }
        let averageTime = totalCompletionTime / Double(completedTasks.count)
        
        return averageTime.isInfinite || averageTime.isNaN ? 0 : averageTime
    }

    // Sorts tasks based on the selected sort option (title, due date, priority, tags, or custom order).
    func sortedTasks() -> [Task] {
        switch sortOption {
        case .title:
            return tasks.sorted { $0.title < $1.title }
        case .dueDate:
            return tasks.sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
        case .priority:
            return tasks.sorted { $0.priority.rawValue < $1.priority.rawValue }
        case .tags:
            return tasks.sorted { $0.tags.joined(separator: ", ") < $1.tags.joined(separator: ", ") }
        case .custom:
            return customSortedTasks()  // Custom sorting based on the saved custom order.
        }
    }

    // Sorts tasks based on the custom order, ensuring tasks not in the customOrder list are included.
    private func customSortedTasks() -> [Task] {
        var sortedTasks: [Task] = []
        for id in customOrder {
            if let task = tasks.first(where: { $0.id == id }) {
                sortedTasks.append(task)
            }
        }
        for task in tasks where !customOrder.contains(task.id) {
            sortedTasks.append(task)
        }
        return sortedTasks
    }

    // Reorders tasks based on drag-and-drop actions in a SwiftUI List.
    func moveTasks(from source: IndexSet, to destination: Int) {
        customOrder.move(fromOffsets: source, toOffset: destination)
        saveTasks()
    }

    // Exports tasks to a CSV format for external use.
    func exportTasks() -> String {
        var csvString = "Title,Due Date,Priority,Category,Completed\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        for task in tasks {
            let dueDate = task.dueDate != nil ? dateFormatter.string(from: task.dueDate!) : ""
            csvString.append("\(task.title),\(dueDate),\(task.priority.rawValue),\(task.category.rawValue),\(task.isCompleted)\n")
        }
        
        return csvString
    }

    // Imports tasks from a CSV format and adds them to the task list.
    func importTasks(from csvString: String) {
        let rows = csvString.split(separator: "\n")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for row in rows.dropFirst() {
            let columns = row.split(separator: ",")
            if columns.count == 5 {
                let title = String(columns[0])
                let dueDate = dateFormatter.date(from: String(columns[1]))
                let priority = Priority(rawValue: String(columns[2])) ?? .medium
                let category = Category(rawValue: String(columns[3])) ?? .other
                let isCompleted = Bool(String(columns[4])) ?? false
                let task = Task(title: title, isCompleted: isCompleted, dueDate: dueDate, priority: priority, category: category)
                addTask(task)
            }
        }
    }

    // Returns tasks that are due on the specified date.
    func tasksForDate(_ date: Date) -> [Task] {
        return tasks.filter { Calendar.current.isDate($0.dueDate ?? Date(), inSameDayAs: date) }
    }
}
