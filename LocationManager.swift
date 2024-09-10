import CoreLocation

// LocationManager is responsible for handling location updates, requesting location permissions, and fetching weather data
// based on the user's current location. It integrates with the CoreLocation framework and a WeatherService.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()            // Instance of CLLocationManager to manage location services.
    @Published var currentLocation: CLLocation?          // Published property to store the user's current location.
    @Published var locationError: Error?                 // Published property to store any location-related errors.
    
    var weatherService: WeatherService?                  // An optional instance of WeatherService to fetch weather data.
    @Published var weatherData: WeatherData?             // Published property to store the fetched weather data.

    // Initializes the LocationManager, sets its delegate, configures accuracy, and starts requesting location updates.
    override init() {
        super.init()
        manager.delegate = self                           // Set the delegate to the current instance.
        manager.desiredAccuracy = kCLLocationAccuracyBest // Request the most accurate location data available.
        manager.requestWhenInUseAuthorization()          // Request location access while the app is in use.
        manager.startUpdatingLocation()                  // Start receiving location updates.
    }

    // Function to explicitly request location permissions from the user.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    // Delegate method that is called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Update the currentLocation property on the main thread.
            DispatchQueue.main.async {
                self.currentLocation = location
                print("User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                // If a WeatherService instance is available, fetch the weather data for the current location.
                if let weatherService = self.weatherService {
                    weatherService.fetchWeather(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ) { result in
                        DispatchQueue.main.async {
                            // Handle the result of the weather fetch operation.
                            switch result {
                            case .success(let weatherData):
                                self.weatherData = weatherData
                            case .failure(let error):
                                print("Error fetching weather: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }

    // Delegate method that is called when the location manager fails to retrieve the user's location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        // Update the locationError property on the main thread to reflect the error.
        DispatchQueue.main.async {
            self.locationError = error
        }
    }
}
