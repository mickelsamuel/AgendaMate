import Foundation

// WeatherService is responsible for fetching weather data from the WeatherAPI.
// It uses latitude and longitude to request the weather forecast for a specific location.
class WeatherService: ObservableObject {
    // API key for the WeatherAPI service.
    static let apiKey = "51c0b12601a748879ac04630241107"
    
    // Base URL for the WeatherAPI service.
    static let baseUrl = "https://api.weatherapi.com/v1/forecast.json"

    // Fetches the weather data for a given latitude and longitude. It retrieves a 3-day weather forecast.
    // The result is returned via a completion handler, which either provides the fetched WeatherData on success or an error on failure.
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        // Construct the URL string by embedding the latitude, longitude, API key, and the number of forecast days.
        let urlString = "\(WeatherService.baseUrl)?key=\(WeatherService.apiKey)&q=\(latitude),\(longitude)&days=3"
        
        // Ensure the URL is valid; otherwise, return without making a network request.
        guard let url = URL(string: urlString) else { return }

        // Create a data task to fetch the weather data asynchronously.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check if data was received and there are no errors; otherwise, return the error.
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            do {
                // Attempt to decode the received data into the WeatherData structure.
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                print("Decoded Weather Data: \(weatherData)")
                // On success, return the decoded WeatherData via the completion handler.
                completion(.success(weatherData))
            } catch {
                // If decoding fails, log the raw JSON response and return the error via the completion handler.
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                completion(.failure(error))
            }
        }
        // Start the network request.
        task.resume()
    }
}

// The top-level structure representing the weather data returned by the WeatherAPI.
// It contains information about the location and a forecast.
struct WeatherData: Codable {
    let location: Location       // The location details (e.g., city, region, country).
    let forecast: Forecast       // The forecast for the location.
}

// Represents the location details such as city, region, and country.
struct Location: Codable {
    let name: String            // Name of the city or location.
    let region: String          // Region or state of the location.
    let country: String         // Country of the location.
}

// Represents the forecast details, which contains an array of forecast days.
struct Forecast: Codable {
    let forecastday: [ForecastDay] // Array of forecast data for each day.
}

// Represents the weather forecast for a specific day.
struct ForecastDay: Codable {
    let date: String            // Date of the forecast (in YYYY-MM-DD format).
    let day: Day                // Contains the detailed weather information for the day.
}

// Represents detailed weather information for a specific day.
struct Day: Codable {
    let maxtemp_c: Double       // Maximum temperature in Celsius.
    let mintemp_c: Double       // Minimum temperature in Celsius.
    let condition: Condition    // Weather condition (e.g., sunny, cloudy, etc.).
}

// Represents the weather condition, including descriptive text and an icon URL for the weather.
struct Condition: Codable {
    let text: String            // Descriptive text of the weather (e.g., "Sunny").
    let icon: String            // URL to the weather icon image.
}
