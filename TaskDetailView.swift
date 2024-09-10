import SwiftUI
import EventKit
import UIKit

// A view for editing the details of an individual task, including its title, completion status, due date, priority, category,
// subtasks, comments, and reminders. The view allows the user to share, save, and delete tasks.
struct TaskDetailView: View {
    // Environment variable to control the presentation mode, allowing for the view to be dismissed.
    @Environment(\.presentationMode) var presentationMode
    
    // The task being edited, wrapped in an `ObservedObject` to reflect changes in the view.
    @ObservedObject var task: Task
    
    // State variables for tracking task details and UI interactions.
    @State private var title: String
    @State private var isCompleted: Bool
    @State private var dueDate: Date
    @State private var priority: Priority
    @State private var category: Category
    @State private var reminderDate: Date?
    @State private var recurring: Bool
    @State private var recurrenceFrequency: RecurrenceFrequency
    @State private var newSubtaskTitle: String = ""
    @State private var newCommentText: String = ""
    @State private var showDeleteAlert = false
    
    // Initializes the view with the current values of the task properties.
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _isCompleted = State(initialValue: task.isCompleted)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _priority = State(initialValue: task.priority)
        _category = State(initialValue: task.category)
        _reminderDate = State(initialValue: task.reminderDate)
        _recurring = State(initialValue: task.recurring)
        _recurrenceFrequency = State(initialValue: task.recurrenceFrequency)
    }
    
    var body: some View {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return Form {
            // Section for task details such as title, completion status, due date, priority, and category.
            Section(header: Text("Task Details")) {
                TextField("Title", text: $title)
                Toggle("Completed", isOn: $isCompleted)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                Picker("Priority", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                // Display the attached image if available.
                if let image = task.attachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            
            // Section for subtasks associated with the task.
            Section(header: Text("Subtasks")) {
                ForEach(task.subtasks) { subtask in
                    HStack {
                        Text(subtask.title)
                        Spacer()
                        if subtask.isCompleted {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                }
                HStack {
                    TextField("New Subtask", text: $newSubtaskTitle)
                    Button(action: addSubtask) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            // Section for comments associated with the task.
            Section(header: Text("Comments")) {
                ForEach(task.comments) { comment in
                    VStack(alignment: .leading) {
                        Text(comment.text)
                        Text(comment.date, formatter: formatter)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    TextField("New Comment", text: $newCommentText)
                    Button(action: addComment) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            // Section for configuring reminders and recurrence for the task.
            Section(header: Text("Reminder")) {
                Toggle("Set Reminder", isOn: Binding(
                    get: { reminderDate != nil },
                    set: { if $0 { reminderDate = Date() } else { reminderDate = nil } }
                ))
                if reminderDate != nil {
                    DatePicker("Reminder Date", selection: Binding($reminderDate)!, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Recurring", isOn: $recurring)
                    if recurring {
                        Picker("Frequency", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                }
            }
            
            // Section for deleting the task.
            Section {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Task")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Edit Task")
        // Save and share buttons in the navigation bar.
        .navigationBarItems(
            trailing: HStack {
                Button(action: shareTask) {
                    Image(systemName: "square.and.arrow.up")
                }
                Button("Save", action: saveTask)
            }
        )
        // Alert to confirm task deletion.
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteTask()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Function to share task details using the system share sheet.
    private func shareTask() {
        let taskDetails = """
        Task Title: \(task.title)
        Completed: \(task.isCompleted ? "Yes" : "No")
        Due Date: \(task.dueDate?.formatted() ?? "N/A")
        Priority: \(task.priority.rawValue)
        Category: \(task.category.rawValue)
        """
        
        let activityViewController = UIActivityViewController(activityItems: [taskDetails], applicationActivities: nil)
        
        // Present the share sheet.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Function to add a new subtask to the task.
    private func addSubtask() {
        let newSubtask = Subtask(title: newSubtaskTitle)
        task.subtasks.append(newSubtask)
        newSubtaskTitle = ""
    }

    // Function to add a new comment to the task.
    private func addComment() {
        let newComment = Comment(text: newCommentText)
        task.comments.append(newComment)
        newCommentText = ""
    }

    // Function to save the task with updated details and dismiss the view.
    private func saveTask() {
        task.title = title
        task.isCompleted = isCompleted
        task.dueDate = dueDate
        task.priority = priority
        task.category = category
        task.reminderDate = reminderDate
        task.recurring = recurring
        task.recurrenceFrequency = recurrenceFrequency

        TaskManager.shared.updateTask(task)
        presentationMode.wrappedValue.dismiss()
    }
    
    // Function to delete the task and dismiss the view.
    private func deleteTask() {
        TaskManager.shared.deleteTask(task)
        presentationMode.wrappedValue.dismiss()
    }

    // Function to schedule a notification for the task's reminder.
    private func scheduleNotification(for task: Task) {
        guard let reminderDate = task.reminderDate else { return }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: task.recurring)

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
