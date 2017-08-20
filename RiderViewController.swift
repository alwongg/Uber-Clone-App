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
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // working with locations, getting best accuracy of location and always updating location
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // check if there is a current ride request when user logs in so they can see "cancel" instead of "call" an uber
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                self.uberHasBeenCalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                
                //remove observer otherwise it'll keep deleting requests!
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestsDictionary = snapshot.value as? [String:AnyObject]{
                    if let driverLat = rideRequestsDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestsDictionary["driverLon"] as? Double {
                            
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            
                            self.driverOnTheWay = true
                            
                            self.displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email{
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    if let rideRequestsDictionary = snapshot.value as? [String:AnyObject]{
                                        if let driverLat = rideRequestsDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestsDictionary["driverLon"] as? Double {
                                                
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                
                                                self.driverOnTheWay = true
                                                
                                                self.displayDriverAndRider()
                                                
                                                
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - IBActions
    
    // MARK: - Call an Uber method
    
    @IBAction func callUber(_ sender: Any) {
        
        if !driverOnTheWay{
            
            // get email of user so we can send user's coordinates to database to give rider info to uber driver
            if let email = Auth.auth().currentUser?.email{
                
                // now we have the email of the user, check if the user has called for an uber
                // if the user has called for an uber, do the following:
                if uberHasBeenCalled {
                    
                    // uber has been called, user can only cancel request so when user presses button, they are pressing "Cancel Uber"
                    // "Cancel Uber" pressed, change uberHasBeenCalled property to false and change title back to "Call an Uber"
                    uberHasBeenCalled = false
                    callUberButton.setTitle("Call an Uber", for: .normal)
                    
                    // UI Update finished but now need to cancel the uber request in Firebase database
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        snapshot.ref.removeValue()
                        
                        //remove observer otherwise it'll keep deleting requests!
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    })
                    
                } else {
                    
                    // no request has been made by user so when tapped, put a request in to database to call an uber
                    let rideRequestDictionary: [String: Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    // after calling an uber, the state of uberHasBeenCalled is set to true
                    // change title of button to "Cancel Uber" after calling an Uber
                    uberHasBeenCalled = true
                    callUberButton.setTitle("Cancel Uber", for: .normal)
                    
                }
            }
        }
    }
    
    // MARK: - Logout User method
    
    @IBAction func logoutUser(_ sender: Any) {
        
        // UI Update: go back to login screen via dismissing navigationcontroller
        navigationController?.dismiss(animated: true, completion: nil)
        
        // need to log out of firebase as well
        try? Auth.auth().signOut()
        
    }
    
    // MARK: - Location Manager method
    
    // tells the delegate that new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // called when there is an update to location
        // get user's current location
        if let coordinates = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
            if uberHasBeenCalled{
                
                displayDriverAndRider()
                
                
            } else {
                
                // set region with center and span info and add geographic region to the map
                let region = MKCoordinateRegion(center: center, span: span)
                mapView.setRegion(region, animated: true)
                
                // assign center to userLocation to store location data for future use
                userLocation = center
                
                // map will zoom in on the region but no annotation
                // create annotation so we can see where the user is
                // remove annotations before setting new ones
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                
                // annotation will have a title "Your location"
                annotation.title = "Your location"
                mapView.addAnnotation(annotation)
                mapView.removeAnnotations(mapView.annotations)
                
            }
        }
    }
    
    func displayDriverAndRider(){
        
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        // calculate the distance between driver and rider's location to see how far they are apart and store data in distance
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        // round the distance
        let roundedDistance = round(distance * 100) / 100
        
        callUberButton.setTitle("Your driver is \(roundedDistance) km away!", for: .normal)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your Location"
        mapView.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your driver"
        mapView.addAnnotation(driverAnnotation)
        
    }
}
