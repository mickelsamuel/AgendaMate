import SwiftUI

class AppLockManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @AppStorage("isAppLocked") private var isAppLocked: Bool = false

    func lockApp() {
        if isAppLocked {
            isUnlocked = false
        }
    }
}
