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

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Connect UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewOption: UISegmentedControl!
    @IBAction func viewOptionChanged(_ sender: Any) {
        // remove previous pins
        mapView.removeAnnotations(mapView.annotations)
        // start new search
        searchInMap()
    }
    
    // Map
    var locationManager = CLLocationManager()
    var request = MKLocalSearch.Request()
    var matchingItems: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        // Change segmented control text size
        let font = UIFont.systemFont(ofSize: 11)
        viewOption.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        // Check location authorisation
        checkLocationServices()
        // Setup location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        // Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: K.delta, longitudeDelta: K.delta)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: true)
        }

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        searchInMap()
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
           checkAuthorizationStatus()
        } else {
           // Do something to let users know why they need to turn it on.
        }
    }

    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        
      case .authorizedWhenInUse:
        mapView.showsUserLocation = true
        
       case .denied:
        // Show alert telling users how to turn on permissions
       break
        
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
      
      case .restricted:
        // Show an alert letting them know what’s up
       break
      
      case .authorizedAlways:
       break
      }
    }
    
    func searchInMap() {
        // map search request
        request.naturalLanguageQuery = viewOption.titleForSegment(at: viewOption.selectedSegmentIndex)
        
        if let userLocation = locationManager.location?.coordinate {
            // search request region
            let span = MKCoordinateSpan(latitudeDelta: K.delta, longitudeDelta: K.delta)
            request.region = MKCoordinateRegion(center: userLocation, span: span)
            // begin searcj
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: {(response, error) in
                for item in response!.mapItems {
                    self.addPinToMapView(title: item.name, latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                }
            })
        }
    }
    
    func addPinToMapView(title: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if let title = title {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = title
            mapView.addAnnotation(annotation)
        }
    }
}

    // MARK: - Delegate Methods

extension LocationViewController {
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
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = viewOption.titleForSegment(at: viewOption.selectedSegmentIndex)
//        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        view.canShowCallout = true
//        view.calloutOffset = CGPoint(x: -5, y: 5)
//        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        return view
//    }
}

