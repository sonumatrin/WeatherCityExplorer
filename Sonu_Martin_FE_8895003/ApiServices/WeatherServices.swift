//
//  Services.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 11/08/23.
//

import Foundation
import CoreLocation

class WeatherService {
    func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: @escaping (Weathers?) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=16e3e8da457fad242caa24396fae6b31&units=metric"

        let session = URLSession(configuration: .default)
        if let temporaryUrl = URL(string: url) {
            let networkTask = session.dataTask(with: temporaryUrl) { data, _, error in
                if let tempdata = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodeData = try decoder.decode(Weathers.self, from: tempdata)
                        completionHandler(decodeData)
                    } catch {
                        print("Error decoding weather data: \(error)")
                        completionHandler(nil)
                    }
                } else {
                    print("Error while fetching weather data: \(error?.localizedDescription ?? "Unknown Error")")
                    completionHandler(nil)
                }
            }
            // Start the data task to initiate the network request
            networkTask.resume()
        } else {
            print("Invalid URL: \(url)")
            completionHandler(nil)
        }
    }
}

