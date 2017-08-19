//
//  RiderViewController.swift
//  Uber Clone
//
//  Created by Alex Wong on 8/18/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Working with locations
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // check if there is a current ride request when user logs in so they can see "cancel" instead of "call"
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                self.uberHasBeenCalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                
                //remove observer otherwise it'll keep deleting requests!
                Database.database().reference().child("RideRequests").removeAllObservers()
            })
            
        }
        
    }
    
    @IBAction func callUber(_ sender: Any) {
        
        // Get email of user so we can send user's coordinates to database to tell uber driver
        if let email = Auth.auth().currentUser?.email{
            
            if uberHasBeenCalled {
           
                uberHasBeenCalled = false
                callUberButton.setTitle("Call an Uber", for: .normal)
                
                // Cancel from the database
                
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    
                    //remove observer otherwise it'll keep deleting requests!
                    Database.database().reference().child("RideRequests").removeAllObservers()
                })
                
            } else {
                
                let rideRequestDictionary: [String: Any] = ["email": email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                
                uberHasBeenCalled = true
                callUberButton.setTitle("Cancel Uber", for: .normal)
                
                
            }
            
         
            
            
            
            
            
            
            
        }
        
        
    }
    
    
    @IBAction func logoutUser(_ sender: Any) {
        
        // get out of firebase
        try? Auth.auth().signOut()
        
        // Go back to login screen via navigationcontroller
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // called when there is an update to location
        
        // Get user's current location
        if let coordinates = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            
            // Create annotation so we can see where we are!
            // remove annotations before setting new ones
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your location"
            mapView.addAnnotation(annotation)
        }
    }
    
}
