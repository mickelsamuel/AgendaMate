import UserNotifications

// A class that handles user notifications. This class conforms to `UNUserNotificationCenterDelegate` and is responsible
// for managing how notifications are presented when the app is in the foreground.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // A shared singleton instance of `NotificationDelegate` for global access.
    static let shared = NotificationDelegate()

    // Private initializer to enforce the singleton pattern, ensuring only one instance of `NotificationDelegate` is created.
    private override init() {
        super.init()
    }

    // Delegate method that handles how notifications are presented when the app is in the foreground.
    // This method is called when a notification is about to be presented while the app is open.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Specify that the notification should display an alert and play a sound when the app is in the foreground.
        completionHandler([.alert, .sound])
    }
}
