//
//  MapViewController.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 11/08/23.
//

import UIKit
import CoreLocation
import MapKit

class Map: UIViewController {
    
    // MARK: - Variables
    
    var cityName: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapZoomSlider: UISlider!
    @IBOutlet var cityInfoTextView: UITextView!
    
    // MARK: - App Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation title
        self.navigationItem.title = "Map"
        
        //Update TextView Values
        if let cityName = cityName, let latitude = latitude, let longitude = longitude {
            let formattedText = "City Name: \(cityName)\nLatitude: \(latitude)\nLongitude: \(longitude)"
                cityInfoTextView.text = formattedText
        } else {
            cityInfoTextView.text = "Data not available"
        }
        
        // Check if city name and coordinates are available
        if let cityName = cityName, let latitude = latitude, let longitude = longitude {
            // Create a coordinate for the city
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // Create a map annotation for the city
            let annotation = MKPointAnnotation()
            annotation.title = cityName
            annotation.coordinate = coordinate
            
            // Add the annotation to the map
            mapView.addAnnotation(annotation)
            // Center the map on the city's coordinates
            mapView.setCenter(coordinate, animated: true)
            
            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate,span: regionSpan)
            
            mapView.setRegion(region, animated: true)
            
            // Set up slider action
            mapZoomSlider.addTarget(self, action: #selector(zoomSliderValueChanged), for: .valueChanged)
        }
    }
    // MARK: - Helper Methods
    
    @objc func zoomSliderValueChanged() {
        //Handling Zoom Control for Slider
        let maxZoomLevel: CLLocationDegrees = 1000000
        let sliderValue = Double(mapZoomSlider.value)
        let newZoomLevel = maxZoomLevel - (maxZoomLevel * sliderValue)
        
        // Create a new region with the updated zoom level
        let center = mapView.region.center
        let updatedRegion = MKCoordinateRegion(center: center, latitudinalMeters: newZoomLevel, longitudinalMeters: newZoomLevel)
        
        // Set the new region to the map view
        mapView.setRegion(updatedRegion, animated: true)
    }
}
