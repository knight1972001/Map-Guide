//
//  ViewController.swift
//  Assignment3
//
//  Created by Đỗ Mai Khánh Nhi on 23/03/2023.
//

import UIKit
import MapKit
import SwiftUI

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate {
    
    struct Location: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
    
    var locations = [
        Location(name: "The Great Wall of China", coordinate: CLLocationCoordinate2D(latitude: 40.431908, longitude: 116.570374)),
        Location(name: "Chichén-Itzá, Mexico", coordinate: CLLocationCoordinate2D(latitude: 20.682985, longitude: -88.568649)),
        Location(name: "Petra, Jordan", coordinate: CLLocationCoordinate2D(latitude: 30.328960, longitude: 35.444832)),
        Location(name: "Machu Picchu, Peru", coordinate: CLLocationCoordinate2D(latitude: -13.163068, longitude: -72.545128)),
        Location(name: "Christ the Redeemer, Rio de Janiero", coordinate: CLLocationCoordinate2D(latitude: -22.908333, longitude: 43.196388)),
        Location(name: "Colosseum, Rome", coordinate: CLLocationCoordinate2D(latitude: 41.890251, longitude: 12.492373)),
        Location(name: "Taj Mahal, India", coordinate: CLLocationCoordinate2D(latitude: 27.173891, longitude: 78.042068))
    ]
    
    @IBOutlet weak var mapView: MKMapView!
    let regionInMeters: Double = 1000
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locations.count
    }
    
 
    //delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row].name;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //when picked
        let region = MKCoordinateRegion.init(center: locations[row].coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters);
        mapView.setRegion(region, animated: true)
        self.drawPoly(destinationLocation: locations[row].coordinate)
    }
    
    @IBOutlet weak var locationPicker: UIPickerView!
    
    let locationManager = CLLocationManager();
    
    var directions: MKDirections!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationPicker.dataSource = self;
        locationPicker.delegate = self;
        mapView.delegate = self
//        view.addSubview(mapView)
        checkLocationServices()
        pinAllLocation()
//        checkLocationServices()
        
    }
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        geocodeAddress()
    }

    func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.showAlertError(message: "Geocoding Error. No place found!")
                return
            }
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                self.showAlertError(message: "No placemarks found!")
                return
            }
            print("FOUND:")
            print(placemark)
            //add to array
            self.locations.append(Location(name: (placemark.name ?? "Error") + ", " + (placemark.country ?? "error"), coordinate: placemark.location?.coordinate ?? CLLocationCoordinate2D()))
            //move to destination
            let region = MKCoordinateRegion.init(center: placemark.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters);
            self.mapView.setRegion(region, animated: true)
            //update pickerView
            self.locationPicker.reloadAllComponents();
            //Add Pin
            let pin = MKPointAnnotation()
            pin.coordinate = placemark.location?.coordinate ?? CLLocationCoordinate2D()
            pin.title = placemark.name
            self.mapView.addAnnotation(pin)
            
            //Show polyline:
            self.drawPoly(destinationLocation: placemark.location?.coordinate ?? CLLocationCoordinate2D())
        }
    }
    
    func drawPoly(destinationLocation: CLLocationCoordinate2D){
//        mapView = MKMapView(frame: view.bounds)
        
        
        // Set up the source and destination locations
        let sourceLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D();
        
        // Create placemark objects for the source and destination locations
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        // Create map items for the source and destination placemarks
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create a directions request using the source and destination map items
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile
        
        // Create an instance of MKDirections using the request
        directions = MKDirections(request: directionsRequest)
        
        // Calculate the route and add it to the map view
        directions.calculate { [weak self] (response, error) in
            guard let self = self, let response = response else {
                self?.showAlertError(message: "Cannot find the route!")
                return; }
            if let route = response.routes.first {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        }
    }

    // MKMapViewDelegate method to render the overlay on the map
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    
    func showAlertError(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func pinAllLocation(){
        for item in locations{
            let pin = MKPointAnnotation()
            pin.coordinate = item.coordinate
            pin.title = item.name
            mapView.addAnnotation(pin)
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters);
            mapView.setRegion(region, animated: true)
            print(location);
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true;
            centerViewOnUserLocation();
            locationManager.startUpdatingLocation();
            break;
        case .denied:
            break;
        case .restricted:
            break;
        case .authorizedAlways:
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}



