//
//  LocationInfoViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 02/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation

class LocationInfoViewController: UIViewController {

    // Attach UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBAction func directionsBtn(_ sender: Any) {
        openMapsAppWithDirections(to: coordinates, destinationName: name)
    }
    
    // Location info
    var name: String!
    var number: String!
    var coordinates: CLLocationCoordinate2D!
    var placemark: String!
    
//    override func viewWillAppear(_ animated: Bool) {
//        // Show navigation bar
//        self.navigationController?.isNavigationBarHidden = false
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        // Make navigation bar opaque
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        // Fill location data
        loadData()

    }
    
    func loadData() {
        // Location Title
        locationName.text = name
        
        // Location Address
        locationAddress.text = placemark
        
        // Map View
        let span = MKCoordinateSpan(latitudeDelta: K.delta, longitudeDelta: K.delta)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)
        mapView.layer.cornerRadius = 15
        
        // Add pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
      let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = name // Provide the name of the destination in the To: field
      mapItem.openInMaps(launchOptions: options)
    }

}
