import SwiftUI
import UserNotifications

// The main entry point for the TodoList app. This struct is responsible for initializing the app,
// setting up the notification and calendar permissions, and configuring the app's primary scene.
@main
struct TodoListApp: App {

    // Environment property to detect app state changes
    @Environment(\.scenePhase) var scenePhase

    // Initializer for the app. This is where notification permissions and calendar access are requested.
    init() {
        // Request user notification permissions (alert, badge, sound).
        requestNotificationPermissions()

        // Request access to the user's calendar.
        requestCalendarAccess()

        // Set the notification delegate to handle incoming notifications while the app is running.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        // Defines the main scene of the app, which uses ContentView as the root view.
        // The Core Data managed object context is passed down through the environment.
        WindowGroup {
            ContentView()
        }
    }

    // Requests user notification permissions for displaying alerts, badges, and sounds.
    // If permissions are granted, a success message is printed. If an error occurs, it is logged.
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permissions granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // Requests access to the user's calendar. If access is granted, a success message is printed.
    // Otherwise, the error is logged.
    func requestCalendarAccess() {
        CalendarManager.shared.requestAccess { granted, error in
            if granted {
                print("Calendar access granted")
            } else if let error = error {
                print("Calendar access denied: \(error.localizedDescription)")
            }
        }
    }
}
