//
//  ViewController.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 10/08/23.
//

import UIKit
import CoreLocation
import CoreData

class Main: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var cityNameTextField: UITextField!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var weatherButton: UIButton!
    
    // MARK: - Variables
    
    let fetchCityImage = FetchCityImageService()
    let locationManager = CLLocationManager()
    
    var activeTextField: UITextField?
    var originalViewFrame: CGRect?
    
    // MARK: - App Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUI(to: mapButton)
        loadUI(to: weatherButton)
        loadUI(to: cityNameTextField)
        
        //Adding keyboard tap gesture
        cityNameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Subscribe to keyboard notifications for textfield move up while keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Making textfield empty after back to view
        cityNameTextField.text = ""
    }
    
    // MARK: - Outlets Actions
    @IBAction func mapButtonTap(_ sender: Any) {
        
        guard let cityName = cityNameTextField.text, !cityName.isEmpty else {
            // Show an alert the user that a city name is required when textfield empty
            showAlert(message: "Please enter a city name!!")
            return
        }
        
        //Intialize a gecoder for fetching latitude and longitude from City Name
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [self] placemarks, error in
            if let error = error {
                // Handle geocoding error
                self.showAlert(message: "Invalid city name! Please enter a valid city name!")
                print("Geocoding error: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first,
                      let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                //Api call for fetching city image and Save Data to Core Data
                fetchCityImage.fetchCityImage(cityName: cityName) { imageData in
                    if let imageData = imageData {
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            // Save the data to CoreDate
                            self.saveDataToCoreData(cityName: cityName, latitude: latitude, longitude: longitude, cityImageName: imageData)
                        }
                    }
                }
                // Create an instance of MapViewController and set its properties
                let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! Map
                mapViewController.cityName = cityName
                mapViewController.latitude = latitude
                mapViewController.longitude = longitude
                
                //Push the MapVC
                self.navigationController?.pushViewController(mapViewController, animated: true)
            }
        }
    }
    
    @IBAction func weatherButtonTap(_ sender: Any) {
        
        guard let cityName = cityNameTextField.text, !cityName.isEmpty else {
            // Show an alert the user that a city name is required when textfield empty
            showAlert(message: "Please enter a city name!!")
            return
        }
        
        //Intialize a gecoder
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [self] placemarks, error in
            if let error = error {
                // Handling  geocoding error
                self.showAlert(message: "Invalid city name! Please enter a valid city name!")
                print("Geocoding error: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first,
                      let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                //Api call for fetching city image
                fetchCityImage.fetchCityImage(cityName: cityName) { imageData in
                    if let imageData = imageData {
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            // Save the data to CoreDate
                            self.saveDataToCoreData(cityName: cityName, latitude: latitude, longitude: longitude, cityImageName: imageData)
                        }
                    }
                }
                
                //Creating weather ViewController and push 
                let weatherViewController = self.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! Weather
                
                weatherViewController.cityName = cityName
                weatherViewController.latitude = latitude
                weatherViewController.longitude = longitude
                
                self.navigationController?.pushViewController(weatherViewController, animated: true)
            }
        }
    }
    
    @IBAction func historyButtonTap(_ sender: Any) {
        
        let historyTVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryTableVC") as! History
        
        self.navigationController?.pushViewController(historyTVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    //Alert message function
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        // Customize the title text color to red
        if let titleString = alert.title {
            let titleAttributedString = NSAttributedString(string: titleString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            alert.setValue(titleAttributedString, forKey: "attributedTitle")
        }
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveDataToCoreData(cityName: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, cityImageName: Data) {
        // Function to save City Information to Coredata
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)!
        let history = NSManagedObject(entity: entity, insertInto: managedContext)
        history.setValue(cityName, forKey: "cityName")
        history.setValue(latitude, forKey: "latitude")
        history.setValue(longitude, forKey: "longitude")
        history.setValue(cityImageName, forKey: "imageData")
        // Save the context
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadUI(to view: UIView) {
        // Using this function to give little animation to UI Componets
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 4
    }
    
}
// MARK: - Textfieled delegates

extension Main {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        originalViewFrame = self.view.frame
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        originalViewFrame = nil
    }
}
// MARK: - Keyboard Notifications

extension Main {

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        guard let activeTextField = activeTextField, let originalFrame = originalViewFrame else {
            return
        }

        let textFieldBottom = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
        let keyboardTop = self.view.frame.height - keyboardFrame.height

        if textFieldBottom > keyboardTop {
            let yOffset = textFieldBottom - keyboardTop + 10
            let newFrame = CGRect(x: originalFrame.origin.x, y: originalFrame.origin.y - yOffset, width: originalFrame.size.width, height: originalFrame.size.height)
            self.view.frame = newFrame
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if let originalFrame = originalViewFrame {
            self.view.frame = originalFrame
        }
    }
}
