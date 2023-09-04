//
//  Weather.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 11/08/23.
//

import UIKit
import CoreLocation

class Weather: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImgaeView: UIImageView!
    @IBOutlet weak var tempreatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet var cityInfoTextView: UITextView!
    
    // MARK: - Variables
    let clManager = CLLocationManager()
    let weatherService = WeatherService()
    var cityName: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.navigationItem.title = "Weather"
        
        //Update TextView Values
        if let cityName = cityName, let latitude = latitude, let longitude = longitude {
            let formattedText = "City Name: \(cityName)\nLatitude: \(latitude)\nLongitude: \(longitude)"
                cityInfoTextView.text = formattedText
        } else {
            cityInfoTextView.text = "Data not available"
        }
        //Api call and updating UI function call
        updateUI()

    }
    
    func updateUI() {
        if let latitude = latitude , let longitude = longitude {
            weatherService.getWeatherData(latitude: latitude, longitude: longitude) { weatherData in
                if let decodedData = weatherData {
                    print(decodedData)
                    DispatchQueue.main.async {
                        self.cityLabel.text = decodedData.name ?? ""
                        self.weatherLabel.text = decodedData.weather?.first?.main ?? ""
                        self.tempreatureLabel.text = "\(Int(decodedData.main?.temp ?? 0.0))°C"
                        self.humidityLabel.text = "Humidity: \(decodedData.main?.humidity ?? 0)%"
                        self.windLabel.text = "Wind: \(Int(decodedData.wind?.speed ?? 0.0)) km/h"
                        self.weatherImgaeView.image = UIImage(named: self.weatherCondition(conditionID: decodedData.weather?.first?.id ?? 0))
                    }
                } else {
                    print("Weather data not available.")
                    // Handle the case when weather data is not available.
                    DispatchQueue.main.async {
                        self.cityLabel.text = "N/A"
                        self.weatherLabel.text = "N/A"
                        self.tempreatureLabel.text = "N/A"
                        self.humidityLabel.text = "N/A"
                        self.windLabel.text = "N/A"
                        self.weatherImgaeView.image = nil
                    }
                }
            }
        }
    }
    
    func weatherCondition(conditionID: Int) -> String {
        switch conditionID {
            case 200...299:
                return "cloudBolt"
            case 300...399:
                return "cloudDrizzle"
            case 500...599:
                return "cloudRain"
            case 600...699:
                return "cloudSnow"
            case 701...799:
                return "cloudFog"
            case 800:
                return "sunMax"
            case 800...899:
                return "cloud1"
            default:
                return "cloud"
        }
    }
}


