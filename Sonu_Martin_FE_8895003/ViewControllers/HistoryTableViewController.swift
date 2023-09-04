//
//  History.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 12/08/23.
//

import UIKit
import CoreData
import CoreLocation

class History: UITableViewController {
    
    // MARK: - Variables
    var savedSearches: [SearchHistory] = []
    let fetchCityImage = FetchCityImageService()
    
    // Flag to track initial city addition
    let initialCitiesAddedKey = "InitialCitiesAdded"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if initial cities have been added
        if !UserDefaults.standard.bool(forKey: initialCitiesAddedKey) {
            //Adding Intial Preloaded 5 Cities function
            addInitialCities()
            UserDefaults.standard.set(true, forKey: initialCitiesAddedKey)
        }
        
        fetchSavedSearches()
    }
    
    // MARK: - Outlet Actions
    
    @IBAction func addCityTap(_ sender: Any) {
        // Alert for adding new city
        let alertController = UIAlertController(title: "Add City", message: "Enter the name of the city", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "City Name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let cityName = alertController?.textFields?.first?.text else { return }
            
            self?.addCity(cityName: cityName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    func addCity(cityName: String) {
        // Check for empty city name
        let trimmedCityName = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCityName.isEmpty else {
            // Display an alert to the user indicating that the city name is empty
            showErrorAlert(message: "Please enter a city name.")
            return
        }
        // Geocode the city name
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                // Handle geocoding error
                print("Geocoding error: \(error.localizedDescription)")
                self.showErrorAlert(message: "City not found. Please enter a valid city name.")
            } else if let placemark = placemarks?.first, let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                // Fetch city image and Save Data to Core Data
                self.fetchCityImage.fetchCityImage(cityName: cityName) { imageData in
                    if let imageData = imageData {
                        DispatchQueue.main.async {
                            // Save Data to CoreData
                            self.saveDataToCoreData(cityName: cityName, latitude: latitude, longitude: longitude, cityImageName: imageData)
                            self.fetchSavedSearches() // Fetch the updated data
                            self.tableView.reloadData() // Reload the table view
                        }
                    }
                }
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        if let titleString = alertController.title {
            let titleAttributedString = NSAttributedString(string: titleString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            alertController.setValue(titleAttributedString, forKey: "attributedTitle")
        }
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveDataToCoreData(cityName: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, cityImageName: Data) {
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
            print("Data saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func addInitialCities() {
        //Hardcoded cities
        let initialCities = ["Calgary","Halifax","Montreal","Toronto","Vancouver"]
        
        for cityName in initialCities {
            addCity(cityName: cityName)
        }
    }
    
    func fetchSavedSearches() {
        
        //Here retrive saved data from Core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        
        do {
            savedSearches = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch saved data. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table View Data Source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedSearches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        
        let search = savedSearches[indexPath.row]
        if let cityName = search.cityName {
            cell.cityLabel.text = "City: \(cityName)"
        }
            cell.lattitudeLabel.text = "\(search.latitude)"
            cell.longitudeLabel.text = "\(search.longitude)"
        if let imageData = search.imageData  {
            let image = UIImage(data: imageData)
            cell.cityImageView.image = image
        }
        
        // Button Actions in tableview cell
        cell.mapButton.tag = indexPath.row
        cell.mapButton.addTarget(self, action: #selector(mapButtonTapped(_:)), for: .touchUpInside)
        
        cell.weatherButton.tag = indexPath.row
        cell.weatherButton.addTarget(self, action: #selector(weatherButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Setting height of table view
        return 175
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let search = savedSearches[indexPath.row]
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(search) // Delete the Core Data object
            
            do {
                try managedContext.save() // Save the changes
                savedSearches.remove(at: indexPath.row) // Remove from the local array
                tableView.deleteRows(at: [indexPath], with: .fade) // Delete the table view row
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc func mapButtonTapped(_ sender: UIButton) {
        let search = savedSearches[sender.tag]
        let cityName = search.cityName
        let latitude = search.latitude
        let longitude = search.longitude
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! Map
        mapViewController.cityName = cityName
        mapViewController.latitude = latitude
        mapViewController.longitude = longitude
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    @objc func weatherButtonTapped(_ sender: UIButton) {
        let search = savedSearches[sender.tag]
        let cityName = search.cityName
        let latitude = search.latitude
        let longitude = search.longitude
        
        let weatherViewController = storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! Weather
        weatherViewController.cityName = cityName
        weatherViewController.latitude = latitude
        weatherViewController.longitude = longitude
        navigationController?.pushViewController(weatherViewController, animated: true)
    }
}
