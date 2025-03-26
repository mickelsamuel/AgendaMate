import SwiftUI

// TaskRow is a SwiftUI view that represents a row displaying task information.
// It includes a button to mark the task as completed and shows the task title and due date.
struct TaskRow: View {
    @ObservedObject var task: Task             // Observes the task object for changes, allowing the UI to update reactively.
    var backgroundColor: Color                 // Background color for the row.
    var textColor: Color                       // Text color for the task title.

    var body: some View {
        // NavigationLink navigates to the TaskDetailView when the row is tapped.
        NavigationLink(destination: TaskDetailView(task: task)) {
            HStack {
                // Button to toggle the task's completion status.
                Button(action: {
                    withAnimation {
                        task.isCompleted.toggle()      // Toggle the task's completion status with an animation.
                    }
                    TaskManager.shared.updateTask(task) // Update the task in the TaskManager.
                }) {
                    // Change the icon based on whether the task is completed or not.
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray) // Green for completed tasks, gray for incomplete.
                }
                .buttonStyle(BorderlessButtonStyle())  // Use a button style that doesn't add additional visual effects.

                VStack(alignment: .leading) {
                    // Display the task title with a strikethrough if the task is completed.
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.color)   // Use the task's assigned color for the title text.
                    
                    // If the task has a due date, display it in a smaller font.
                    if let dueDate = task.dueDate {
                        Text(formattedDate(dueDate))   // Format and display the due date.
                            .font(.caption)
                            .foregroundColor(.gray)    // Use gray text for the due date.
                    }
                }
                Spacer() // Pushes the content to the left side of the row.
            }
            .background(backgroundColor) // Apply the background color to the row.
        }
    }

    // Helper function to format the task's due date into a user-friendly string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Medium date style (e.g., "Aug 23, 2024").
        return formatter.string(from: date)
    }
}
