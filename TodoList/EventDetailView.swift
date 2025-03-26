import SwiftUI
import EventKit
import MapKit

// A view that allows users to view and edit the details of a calendar event retrieved from EventKit.
// It shows the event's title, start and end dates, location, notes, and other relevant fields.
struct EventDetailView: View {
    // The event to display and edit, passed in as a constant.
    @State var event: EKEvent
    
    // State variables to allow editing of event details.
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var location: String
    @State private var notes: String
    @State private var selectedColor: Color = .blue
    @State private var showingMapPicker = false
    @State private var showingDeleteConfirmation = false  // State variable to show the delete confirmation dialog
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Environment(\.presentationMode) var presentationMode
    
    // Initialize the view with existing event details.
    init(event: EKEvent) {
        self._event = State(initialValue: event)
        self._title = State(initialValue: event.title ?? "")
        self._startDate = State(initialValue: event.startDate)
        self._endDate = State(initialValue: event.endDate)
        self._location = State(initialValue: event.location ?? "")
        self._notes = State(initialValue: event.notes ?? "")
    }
    
    var body: some View {
        // A form layout for viewing and editing the event details.
        Form {
            // Section for editing basic event details.
            Section(header: Text("Event Details")) {
                TextField("Event Title", text: $title)
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                
                // Section for picking the event location.
                TextField("Location", text: $location)
                Button("Pick Location on Map") {
                    showingMapPicker = true
                }
                
                TextField("Notes", text: $notes)
                
                // Color picker for customizing the event color.
                ColorPicker("Event Color", selection: $selectedColor)
            }
            
            // Section for saving the changes or canceling the edit.
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
            
            // Section for deleting the event.
            Section {
                Button("Delete Event") {
                    showingDeleteConfirmation = true  // Show the confirmation dialog when the delete button is pressed
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit Event")
        .sheet(isPresented: $showingMapPicker) {
            // Present the map picker as a sheet when requested.
            MapPickerView(region: $region, selectedPlace: $location)
        }
        .confirmationDialog("Are you sure you want to delete this event?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteEvent()  // Call the delete event function if the user confirms
            }
            Button("Cancel", role: .cancel) {
                // Do nothing, simply dismiss the confirmation dialog
            }
        }
    }
    
    // Function to save the modified event details back to the calendar.
    private func saveChanges() {
        // Update the event properties with the modified details.
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes

        // Attempt to save the event and provide a completion handler.
        CalendarManager.shared.saveEvent(event: event) { success, error in
            if success {
                // Dismiss the view upon success.
                presentationMode.wrappedValue.dismiss()
            } else if let error = error {
                // Handle any errors that might occur while saving the event.
                print("Failed to save event: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to delete the event from the user's calendar.
    private func deleteEvent() {
        CalendarManager.shared.deleteEvent(event: event) { success, error in
            if success {
                // Make sure the event is fully deleted and the view is dismissed.
                presentationMode.wrappedValue.dismiss()
                
                // Optional: Trigger a refresh of your calendar view if necessary.
                // You may need to use notifications or state management to refresh the calendar UI.
            } else if let error = error {
                // Handle any errors that might occur while deleting the event.
                print("Failed to delete event: \(error.localizedDescription)")
            }
        }
    }
}
