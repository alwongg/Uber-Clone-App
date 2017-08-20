//
//  DriverTableViewController.swift
//  Uber Clone
//
//  Created by Alex Wong on 8/19/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var rideRequests: [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    // MARK: - IBActions
    
    @IBAction func logoutUser(_ sender: Any) {
        
        // UI Update: go back to login screen via dismissing navigationcontroller
        navigationController?.dismiss(animated: true, completion: nil)
        
        // need to log out of firebase as well
        try? Auth.auth().signOut()
        
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Location Manager method
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // find current location and store in coordinate if it exists
        if let coordinate = manager.location?.coordinate{
            
            // store location as the driverLocation
            driverLocation = coordinate
            
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set cell reuseIdentifier to "rideRequestCell": this will store all the ride requests made by rider
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        // Configure the cell...
        
        // store rideRequests property at indexPath.row in a constant called snapshot
        let snapshot = rideRequests[indexPath.row]
        
        // store rideRequests as a dictionary
        if let rideRequestsDictionary = snapshot.value as? [String:AnyObject]{
            if let email = rideRequestsDictionary["email"] as? String {
                if let lat = rideRequestsDictionary["lat"] as? Double {
                    if let lon = rideRequestsDictionary["lon"] as? Double{
                        
                        // get the driver CLLocation
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        
                        // get the rider CLLocation
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        // calculate the distance between driver and rider's location to see how far they are apart and store data in distance
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        
                        // round the distance
                        let roundedDistance = round(distance * 100) / 100
                        
                        // update text inside the table view cell to inform driver how far riders are away from them
                        cell.textLabel?.text = "\(email) - \(roundedDistance) km away"
                        
                    }
                }
            }
        }
        return cell
    }
    
    // things to do after a row has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // store ride requests in snapshot
        let snapshot = rideRequests[indexPath.row]
        
        // segue AcceptRequestViewController
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    // REVIEW THIS ASAP
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptViewController = segue.destination as? AcceptRequestViewController{
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestsDictionary = snapshot.value as? [String:AnyObject]{
                    if let email = rideRequestsDictionary["email"] as? String {
                        if let lat = rideRequestsDictionary["lat"] as? Double {
                            if let lon = rideRequestsDictionary["lon"] as? Double{
                                
                                acceptViewController.requestEmail = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptViewController.requestLocation = location
                                acceptViewController.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
        }
    }
}
