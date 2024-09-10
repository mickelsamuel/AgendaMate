import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @Binding var isUnlocked: Bool
    @AppStorage("passcode") private var storedPasscode: String = ""
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @State private var enteredPasscode: String = ""
    @State private var showingPasscodeInput: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("App Locked")
                .font(.title)
                .fontWeight(.bold)

            if showingPasscodeInput {
                PasscodeInputView(enteredPasscode: $enteredPasscode, errorMessage: $errorMessage)
            } else {
                Button("Enter Passcode") {
                    showingPasscodeInput = true
                }
                .buttonStyle(.bordered)
            }

            if isFaceIDEnabled {
                Button("Use Face ID") {
                    authenticateWithFaceID()
                }
                .buttonStyle(.bordered)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            if isFaceIDEnabled {
                authenticateWithFaceID()
            }
        }
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the app") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    } else {
                        errorMessage = "Face ID authentication failed. Please try again or use passcode."
                    }
                }
            }
        } else {
            errorMessage = "Face ID is not available. Please use passcode."
        }
    }
}

struct PasscodeInputView: View {
    @Binding var enteredPasscode: String
    @Binding var errorMessage: String
    @AppStorage("passcode") private var storedPasscode: String = ""

    var body: some View {
        VStack(spacing: 20) {
            PasscodeCircles(passcodeLength: enteredPasscode.count)

            NumberPad(enteredPasscode: $enteredPasscode, maxDigits: 4)

            Button("Unlock") {
                if enteredPasscode == storedPasscode {
                    withAnimation {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                } else {
                    errorMessage = "Incorrect passcode. Please try again."
                    enteredPasscode = ""
                }
            }
            .disabled(enteredPasscode.count != 4)
            .buttonStyle(.bordered)
        }
    }
}

struct NumberPad: View {
    @Binding var enteredPasscode: String
    let maxDigits: Int

    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            self.buttonTapped(number)
                        }) {
                            if number == "⌫" {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 24, weight: .semibold))
                            } else {
                                Text(number)
                                    .font(.system(size: 32, weight: .semibold))
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(number.isEmpty ? Color.clear : Color.secondary.opacity(0.2))
                        .foregroundColor(Color(UIColor.label))
                        .cornerRadius(40)
                        .disabled(number.isEmpty)
                    }
                }
            }
        }
    }

    private func buttonTapped(_ number: String) {
        if number == "⌫" {
            if !enteredPasscode.isEmpty {
                enteredPasscode.removeLast()
            }
        } else if enteredPasscode.count < maxDigits {
            enteredPasscode.append(number)
        }
    }
}
