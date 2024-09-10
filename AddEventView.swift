import SwiftUI
import MapKit
import EventKit

// A view that allows users to create and customize a new calendar event, including details such as title, date, location,
// category, color, tags, comments, reminders, and attachments. The event can also be set as recurring, and locations can be selected on a map.
struct AddEventView: View {
    // Environment variable to control the presentation mode, allowing for the view to be dismissed.
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for tracking event details input by the user.
    @State private var title = ""
    @State private var eventDate = Date()
    @State private var eventEndTime = Date().addingTimeInterval(3600)
    @State private var category = Category.other
    @State private var selectedColor: Color = .blue
    @State private var reminderDate: Date?
    @State private var recurring = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .none
    @State private var tagsText = ""
    @State private var place: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showingMapPicker = false
    @State private var comments = ""
    
    // Region for the map picker, initialized to a specific location (San Francisco).
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // State variable to track the name of the selected place.
    @State private var placeName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Section for entering basic event details such as title, date, end time, category, color, and tags.
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $title)
                    DatePicker("Date", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time", selection: $eventEndTime, displayedComponents: [.hourAndMinute])
                    
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    
                    ColorPicker("Event Color", selection: $selectedColor)
                    
                    TextField("Tags (comma separated)", text: $tagsText)
                    
                    TextField("Add Comments", text: $comments)
                    
                    Button("Attach Image") {
                        showingImagePicker = true
                    }
                    
                    // Display the selected image, if any.
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    // Toggle for setting a reminder for the event.
                    Toggle("Set Reminder", isOn: Binding(
                        get: { reminderDate != nil },
                        set: { newValue in
                            if !newValue {
                                reminderDate = nil
                            } else if reminderDate == nil {
                                reminderDate = Date()
                            }
                        }
                    ))
                    
                    // If a reminder is set, display the options for selecting the reminder date and recurrence frequency.
                    if reminderDate != nil {
                        DatePicker("Reminder Date", selection: Binding(
                            get: { reminderDate ?? Date() },
                            set: { reminderDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                        
                        Toggle("Recurring", isOn: $recurring)
                        if recurring {
                            Picker("Frequency", selection: $recurrenceFrequency) {
                                ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.rawValue.capitalized).tag(frequency)
                                }
                            }
                        }
                    }
                }
                
                // Section for picking the event location, either by searching or selecting a location on the map.
                Section(header: Text("Location")) {
                    TextField("Search for a place", text: $placeName)
                    Button("Pick Location on Map") {
                        showingMapPicker = true
                    }
                    if !place.isEmpty {
                        Text("Selected Place: \(place)")
                    }
                }
            }
            .navigationTitle("Add New Event")
            .navigationBarItems(leading: Button("Cancel") {
                // Dismiss the view when the "Cancel" button is pressed.
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                // Save the event when the "Save" button is pressed.
                saveEvent()
            })
            .sheet(isPresented: $showingImagePicker) {
                // Present the image picker as a sheet when requested.
                CustomImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingMapPicker) {
                // Present the map picker as a sheet when requested.
                MapPickerView(region: $region, selectedPlace: $place)
            }
        }
    }
    
    // Function to save the event to the user's calendar using the CalendarManager.
    private func saveEvent() {
        let tagsArray = tagsText.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Add the event to the calendar using the CalendarManager.
        CalendarManager.shared.addEvent(title: title, startDate: eventDate, endDate: eventEndTime, location: place, notes: comments, completion: { success, error in
            if success {
                print("Event added to Calendar")
            } else {
                print("Failed to add event to Calendar: \(error?.localizedDescription ?? "Unknown error")")
            }
        })
        
        // Dismiss the view after saving the event.
        presentationMode.wrappedValue.dismiss()
    }
}

// A view that allows the user to pick a location on a map. Once the user selects a location, it uses reverse geocoding to retrieve the place name.
struct MapPickerView: View {
    @Binding var region: MKCoordinateRegion  // The current region of the map.
    @Binding var selectedPlace: String  // The name of the selected place.
    @Environment(\.presentationMode) var presentationMode  // Controls dismissal of the view.
    
    var body: some View {
        VStack {
            // Display an interactive map for picking a location.
            Map(coordinateRegion: $region, interactionModes: [.all])
                .edgesIgnoringSafeArea(.all)
            
            // Button to confirm the selected location and retrieve the place name using reverse geocoding.
            Button("Select This Location") {
                let geocoder = CLGeocoder()
                let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let placemark = placemarks?.first {
                        self.selectedPlace = placemark.name ?? "\(region.center.latitude), \(region.center.longitude)"
                    } else {
                        self.selectedPlace = "\(region.center.latitude), \(region.center.longitude)"
                    }
                    // Dismiss the map picker view.
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
    }
}
