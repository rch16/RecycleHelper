//
//  LocationViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 01/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation

class LocationViewController: UIViewController {
    
    // Connect UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewOption: UISegmentedControl!
    @IBAction func viewOptionChanged(_ sender: Any) {
        // remove previous pins
        mapView.removeAnnotations(mapView.annotations)
        // start new search
        searchInMap()
    }
    @IBAction func recentreBtn(_ sender: Any) {
        centreMap()
    }
    
    // Map
    var locationManager = CLLocationManager()
    var request = MKLocalSearch.Request()
    var matchingItems: [MKMapItem] = []
    
    // Segue information
    var locationName: String!
    var location: CLLocationCoordinate2D!
    //var phoneNumber: String!
    var placemark: String!
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true

        // Change segmented control text size
        let font = UIFont.systemFont(ofSize: 11)
        viewOption.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        // Setup mapView delegate
        mapView.delegate = self
        
        // Setup location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        
        // Check for Location Services
        checkLocationServices()
        
        // Zoom to user location
        centreMap()

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        searchInMap()
    }
    
    func checkLocationServices() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        }
    }
    
    func centreMap() {
        if let userLocation = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: K.delta, longitudeDelta: K.delta)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func searchInMap() {
        // map search request
        let currentView = viewOption.titleForSegment(at: viewOption.selectedSegmentIndex)
        if currentView == "Recycling Centres" {
            // Perform a more specific search for recycling centres
            request.naturalLanguageQuery = K.searchQuery
        } else {
            request.naturalLanguageQuery = currentView
        }
        
        if let userLocation = locationManager.location?.coordinate {
            // search request region
            let span = MKCoordinateSpan(latitudeDelta: K.delta, longitudeDelta: K.delta)
            request.region = MKCoordinateRegion(center: userLocation, span: span)
            // begin search
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
                for item in response!.mapItems {
                    self.addPinToMapView(title: item.name, placemark: item.placemark, latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                }
                let searchRegion = response!.boundingRegion
                if searchRegion.span.latitudeDelta < 0.1{
                    // If span < 0.2, zoom out map region to cover all search results
                    self.mapView.setRegion(searchRegion, animated: true)
                } else {
                    // Otherwise limit results shown in view
                    if let userLocation = self.locationManager.location?.coordinate {
                        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        let region = MKCoordinateRegion(center: userLocation, span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            })
        }
    }
    
    func addPinToMapView(title: String?, placemark: CLPlacemark?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if let title = title {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = title
            if let placemark = placemark {
                annotation.subtitle = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
            }
            mapView.addAnnotation(annotation)
        }
    }
}

    // MARK: - CLLocationManagerDelegate Methods

extension LocationViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

}

    // MARK: - MKMapViewDelegate Methods

extension LocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = viewOption.titleForSegment(at: viewOption.selectedSegmentIndex)
        // Look for reusable cell
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier!)
        // Check if annotation is user location or searched location
        if annotation is MKUserLocation {
            // Show default blue dot for user location
            return nil
        } else {
            if annotationView == nil { // If not found
                // Make a new one
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                // Enable pin clusters for multiple pins in a location
                //annotationView?.clusteringIdentifier = "PinCluster"
                // Show Pop up info
                annotationView?.canShowCallout = true
                // Attach an information button
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else { // Reusable view found
                // Give it the new annotation
                annotationView?.annotation = annotation
            }
            return annotationView
        }
    }
    
    // MARK: - Navigation
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        locationName = view.annotation?.title as! String
        location = view.annotation?.coordinate
        if let subtitle = view.annotation?.subtitle {
            placemark = subtitle
        }
        self.performSegue(withIdentifier: K.locationInfoSegue, sender: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationVC = segue.destination as? LocationInfoViewController, segue.identifier == K.locationInfoSegue {
            locationVC.name = locationName
            locationVC.coordinates = location
            locationVC.placemark = placemark
        }
    }
}

