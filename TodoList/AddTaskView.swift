import SwiftUI
import UIKit
import EventKit

// A view that allows the user to add a new task with various properties like title, due date, priority, category,
// color, image, tags, reminder, recurrence, and comments. It also supports adding tasks to the calendar and scheduling notifications.
struct AddTaskView: View {
    // ObservedObject to keep track of the task manager, which handles task creation and management.
    @ObservedObject var taskManager: TaskManager
    
    // State variables for user input.
    @State private var title = ""  // The title of the task.
    @State private var dueDate = Date()  // The due date of the task.
    @State private var priority = Priority.medium  // The priority of the task.
    @State private var category = Category.other  // The category of the task.
    @State private var reminderDate: Date?  // The date for the task's reminder (optional).
    @State private var recurring = false  // Boolean to toggle task recurrence.
    @State private var snoozeEnabled = false  // Boolean to enable snooze for reminders.
    @State private var addToCalendar = false  // Boolean to determine if the task should be added to the calendar.
    @State private var selectedColor: Color = .blue  // The color associated with the task.
    @State private var selectedImage: UIImage? = nil  // The image attached to the task (optional).
    @State private var showingImagePicker = false  // Controls the visibility of the image picker.
    @State private var showingColorPicker = false  // Controls the visibility of the color picker.
    @State private var tagsText = ""  // The tags for the task, entered as a comma-separated string.
    @State private var recurrenceFrequency: RecurrenceFrequency = .none  // The frequency of recurrence for the task.
    
    // New state variables for handling comments.
    @State private var newCommentText = ""  // Text for a new comment.
    @State private var comments: [Comment] = []  // Array of comments associated with the task.
    
    // Environment property to control the presentation mode (dismiss the view).
    @Environment(\.presentationMode) var presentationMode

    // Binding for handling the reminder date.
    private var reminderBinding: Binding<Date> {
        Binding<Date>(
            get: { self.reminderDate ?? Date() },
            set: { self.reminderDate = $0 }
        )
    }

    var body: some View {
        NavigationView {
            // Form structure to collect task details from the user.
            Form {
                // Section for entering task details such as title, due date, priority, category, color, tags, and image.
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                    DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                    
                    // Picker for task priority.
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    // Picker for task category.
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    // Color picker for selecting the task's color.
                    ColorPicker("Task Color", selection: $selectedColor)
                    
                    // TextField for entering tags (comma-separated).
                    TextField("Tags (comma separated)", text: $tagsText)
                    
                    // Button to show the image picker.
                    Button("Attach Image") {
                        showingImagePicker = true
                    }
                    
                    // Display the selected image if any.
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }

                // Section for adding and displaying comments.
                Section(header: Text("Comments")) {
                    // Display existing comments.
                    ForEach(comments) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.text)
                            Text(comment.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Add new comment input field and button.
                    HStack {
                        TextField("New Comment", text: $newCommentText)
                        Button(action: addComment) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }

                // Section for setting reminders and recurrence.
                Section(header: Text("Reminder")) {
                    // Toggle for enabling/disabling reminders.
                    Toggle("Set Reminder", isOn: Binding(
                        get: { self.reminderDate != nil },
                        set: { newValue in
                            if !newValue {
                                self.reminderDate = nil
                            } else if self.reminderDate == nil {
                                self.reminderDate = Date()
                            }
                        }
                    ))
                    
                    // If reminder is set, show additional options for selecting the reminder date, recurrence, and snooze.
                    if reminderDate != nil {
                        DatePicker("Reminder Date", selection: reminderBinding, displayedComponents: [.date, .hourAndMinute])
                        Toggle("Recurring", isOn: $recurring)
                        if recurring {
                            Picker("Frequency", selection: $recurrenceFrequency) {
                                ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                        }
                        Toggle("Snooze Enabled", isOn: $snoozeEnabled)
                        Toggle("Add to Calendar", isOn: $addToCalendar)
                    }
                }
            }
            .navigationTitle("Add New Task")  // Title of the navigation bar.
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },  // Cancel button.
                trailing: Button("Save") { saveTask() }  // Save button.
            )
            .sheet(isPresented: $showingImagePicker) {
                CustomImagePicker(image: $selectedImage)  // Present image picker when button is clicked.
            }
        }
    }

    // Function to add a new comment to the task's comments list.
    private func addComment() {
        let newComment = Comment(text: newCommentText)
        comments.append(newComment)
        newCommentText = ""  // Clear the input field after adding the comment.
    }

    // Function to save the task to the task manager and schedule a notification if a reminder is set.
    private func saveTask() {
        // Split the tags text into an array of tags.
        let tagsArray = tagsText.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Create a new task with the collected data.
        let newTask = Task(
            title: title,
            dueDate: dueDate,
            priority: priority,
            category: category,
            reminderDate: reminderDate,
            recurring: recurring,
            comments: comments,
            color: selectedColor,
            attachedImage: selectedImage,
            tags: tagsArray
        )
        newTask.recurrenceFrequency = recurrenceFrequency
        
        // Add the task to the task manager.
        taskManager.addTask(newTask)
        
        // Schedule a notification if a reminder is set.
        if let reminderDate = reminderDate {
            scheduleNotification(for: newTask, at: reminderDate)
        }

        // Add the task to the calendar if required.
        if reminderDate != nil && addToCalendar {
            let notesText = comments.map { $0.text }.joined(separator: "\n")
       
            CalendarManager.shared.addEvent(
                title: title,
                startDate: reminderDate!,
                endDate: reminderDate!.addingTimeInterval(3600),
                location: nil,
                notes: notesText,
                completion: { success, error in
                    if success {
                        print("Event added to Calendar")
                    } else {
                        print("Failed to add event to Calendar: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            )
        }

        // Dismiss the view after saving the task.
        presentationMode.wrappedValue.dismiss()
    }

    // Function to schedule a notification for the task.
    private func scheduleNotification(for task: Task, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = UNNotificationSound.default

        // Create a notification trigger based on the date.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled: \(request.identifier)")
            }
        }
    }
}
