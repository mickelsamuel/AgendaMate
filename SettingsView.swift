import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    // AppStorage properties for persisting user settings across app launches.
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .blue
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 14.0
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("showTodoList") private var showTodoList: Bool = true
    @AppStorage("showJournal") private var showJournal: Bool = true
    @AppStorage("showNotes") private var showNotes: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true

    // Security settings stored in AppStorage.
    @AppStorage("isAppLocked") private var isAppLocked: Bool = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @AppStorage("passcode") private var passcode: String = ""
    
    // Environment variables to access system-level properties and control the view presentation.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for handling alerts and showing modals.
    @State private var showingPasscodeSetupView = false
    @State private var showingPasscodeChangeView = false
    @State private var showingFaceIDErrorAlert = false
    @State private var showingValidationError = false

    var body: some View {
        NavigationView {
            Form {
                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    HStack {
                        Text("Font Size")
                        Slider(value: $selectedFontSize, in: 12...24, step: 1)
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                // Visibility Section
                Section(header: Text("Visibility")) {
                    Toggle("Show To-Do List", isOn: Binding(
                        get: { showTodoList },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showTodoList") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Journal", isOn: Binding(
                        get: { showJournal },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showJournal") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Notes", isOn: Binding(
                        get: { showNotes },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showNotes") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                    Toggle("Show Calendar", isOn: Binding(
                        get: { showCalendar },
                        set: { newValue in handleToggleChange(newValue: newValue, key: "showCalendar") }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                // Security Section
                Section(header: Text("Security")) {
                    Toggle("Lock App", isOn: Binding(
                        get: { isAppLocked },
                        set: { newValue in handleLockToggleChange(newValue: newValue) }
                    ))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    if isAppLocked {
                        Toggle("Enable Face ID", isOn: $isFaceIDEnabled)
                            .onChange(of: isFaceIDEnabled) { newValue in
                                if newValue {
                                    authenticateWithFaceID()
                                }
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Button("Change Passcode") {
                            showingPasscodeChangeView = true
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .blue)
                        .sheet(isPresented: $showingPasscodeChangeView) {
                            PasscodeSetupView(passcode: $passcode, isChangeMode: true) {
                                print("Passcode changed")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .foregroundColor(colorScheme == .dark ? .white : .blue)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .sheet(isPresented: $showingPasscodeSetupView) {
            PasscodeSetupView(passcode: $passcode, isChangeMode: false) {
                isAppLocked = true
            }
        }
        .alert(isPresented: $showingFaceIDErrorAlert) {
            Alert(
                title: Text("Face ID Error"),
                message: Text("Face ID could not be enabled. Please check your device settings."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleToggleChange(newValue: Bool, key: String) {
        let totalOn = [showTodoList, showJournal, showNotes, showCalendar].filter { $0 }.count
        
        if totalOn == 1 && !newValue {
            showingValidationError = true
        } else {
            switch key {
            case "showTodoList": showTodoList = newValue
            case "showJournal": showJournal = newValue
            case "showNotes": showNotes = newValue
            case "showCalendar": showCalendar = newValue
            default: break
            }
        }
    }

    // Handles the logic when the Lock App switch is toggled
    private func handleLockToggleChange(newValue: Bool) {
        if newValue && passcode.isEmpty {
            showingPasscodeSetupView = true
        } else {
            isAppLocked = newValue
        }
    }
    
    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable Face ID for app security") { success, authenticationError in
                if !success {
                    isFaceIDEnabled = false
                    showingFaceIDErrorAlert = true
                }
            }
        } else {
            isFaceIDEnabled = false
            showingFaceIDErrorAlert = true
        }
    }
}

// A separate view for setting up or changing a passcode with confirmation and old passcode verification.
import SwiftUI

struct PasscodeSetupView: View {
    @Binding var passcode: String
    @State private var enteredPasscode: String = ""
    @State private var newPasscode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var isVerifyingOldPasscode: Bool
    @State private var isConfirmingNewPasscode = false
    @State private var isInvalidPasscode = false
    @State private var errorMessage = ""
    var isChangeMode: Bool
    var onPasscodeSet: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    let keypadNumbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]

    init(passcode: Binding<String>, isChangeMode: Bool, onPasscodeSet: @escaping () -> Void) {
        self._passcode = passcode
        self.isChangeMode = isChangeMode
        self.onPasscodeSet = onPasscodeSet
        self._isVerifyingOldPasscode = State(initialValue: isChangeMode)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(titleText)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(subtitleText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            PasscodeCircles(passcodeLength: currentPasscodeBinding.wrappedValue.count)
                .padding(.vertical)

            VStack(spacing: 15) {
                ForEach(keypadNumbers, id: \.self) { row in
                    HStack(spacing: 30) {
                        ForEach(row, id: \.self) { number in
                            KeypadButton(number: number, action: { handleKeyPress(number) })
                        }
                    }
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }

            Spacer()

            Button(action: handleContinueButton) {
                Text(continueButtonText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .preferredColorScheme(colorScheme) // Respect system color scheme
    }

    private var titleText: String {
        if isVerifyingOldPasscode {
            return "Enter Your Current Passcode"
        } else if isConfirmingNewPasscode {
            return "Confirm Your New Passcode"
        } else {
            return isChangeMode ? "Set Your New Passcode" : "Create Your Passcode"
        }
    }

    private var subtitleText: String {
        if isVerifyingOldPasscode {
            return "Enter your current passcode to proceed"
        } else if isConfirmingNewPasscode {
            return "Re-enter the new passcode to confirm"
        } else {
            return "Enter a 4-digit passcode"
        }
    }

    private var continueButtonText: String {
        if isVerifyingOldPasscode {
            return "Verify Passcode"
        } else if isConfirmingNewPasscode {
            return "Confirm Passcode"
        } else {
            return "Continue"
        }
    }

    private var currentPasscodeBinding: Binding<String> {
        if isVerifyingOldPasscode {
            return $enteredPasscode
        } else if isConfirmingNewPasscode {
            return $confirmPasscode
        } else {
            return $newPasscode
        }
    }

    private func handleKeyPress(_ number: String) {
        let currentPasscode = currentPasscodeBinding
        if number == "⌫" {
            if !currentPasscode.wrappedValue.isEmpty {
                currentPasscode.wrappedValue.removeLast()
            }
        } else if currentPasscode.wrappedValue.count < 4 {
            currentPasscode.wrappedValue.append(number)
        }
        errorMessage = "" // Clear error message on new input
    }

    private func handleContinueButton() {
        if isVerifyingOldPasscode {
            if enteredPasscode == passcode {
                isVerifyingOldPasscode = false
                enteredPasscode = ""
            } else {
                showError("Incorrect passcode. Please try again.")
            }
        } else if isConfirmingNewPasscode {
            if newPasscode == confirmPasscode {
                passcode = newPasscode
                onPasscodeSet()
                presentationMode.wrappedValue.dismiss()
            } else {
                showError("Passcodes do not match. Please try again.")
            }
        } else {
            if newPasscode.count == 4 {
                isConfirmingNewPasscode = true
            } else {
                showError("Please enter a 4-digit passcode.")
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        currentPasscodeBinding.wrappedValue = ""
    }
}

struct PasscodeCircles: View {
    let passcodeLength: Int

    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(index < passcodeLength ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct KeypadButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
