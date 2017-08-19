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

    
    var rideRequests: [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    @IBAction func logoutUser(_ sender: Any) {
        // get out of firebase
        try? Auth.auth().signOut()
        
        // Go back to login screen via navigationcontroller
        
        navigationController?.dismiss(animated: true, completion: nil)

    }
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

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // find driver's location
        
        if let coordinate = manager.location?.coordinate{
            
            driverLocation = coordinate
            
            
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)

        // Configure the cell...

        let snapshot = rideRequests[indexPath.row]
        if let rideRequestsDictionary = snapshot.value as? [String:AnyObject]{
            
            if let email = rideRequestsDictionary["email"] as? String {
                
                if let lat = rideRequestsDictionary["lat"] as? Double {
                    if let lon = rideRequestsDictionary["lon"] as? Double{
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance) km away"
                        
                        
                    }
                    
                    
                }
                
                
            }
            
            
            
        }
        
        
        return cell
    }

}
