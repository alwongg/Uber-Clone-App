//
//  ViewController.swift
//  Uber Clone
//
//  Created by Alex Wong on 8/18/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var signUpMode = true
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwtich: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    
    // MARK: - IBActions
    
    // MARK: - Log in or Sign up user
    @IBAction func topTapped(_ sender: Any) {
        
        // check if email and password text fields are empty, if they are, display alert with error message
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert(title: "Missing Information", message: "You must provide both an email and a password")
            
        } else {
            
            // check if textfields have value, if they do, let's login or sign up
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    
                    // check the mode, if signUpMode is true, sign up, else, log in
                    if signUpMode {
                        
                        // SIGN UP USER MODE
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            
                            // check if there's any error in signing up user, display alert if error exists
                            if error != nil {
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                            } else {
                                
                                // no error exists when creating user so user successfully signed up
                                // when user successfully signed up, do the following
                                
                                
                                if self.riderDriverSwtich.isOn{
                                    
                                    // if switch is on, you will sign up as the driver
                                    // SIGNED UP AS DRIVER
                                    // update a user's basic profile information—the user's display name to "Driver", with the "createProfileChangeRequest" class
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Driver"
                                    request?.commitChanges(completion: nil)
                                    
                                    // segue to driver view controller
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    // print("Driver signed up")
                                    
                                } else {
                                    
                                    // if switch is off, you will sign up as the rider
                                    // SIGNED UP AS RIDER
                                    // update a user's basic profile information—the user's display name to "Rider", with the "createProfileChangeRequest" class
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Rider"
                                    request?.commitChanges(completion: nil)
                                    
                                    // segue to rider view controller
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    // print("Rider signed up")
                                }
                            }
                        })
                    } else {
                        
                        // LOG IN USER MODE
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            
                            // check if there's any error in logging in user, display alert if error exists
                            if error != nil {
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                            } else {
                                
                                // if logged in user has a display name of "Driver", segue to driver view controller
                                if user?.displayName == "Driver"{
                                    
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    // print("Driver")
                                    
                                    
                                    
                                } else {
                                    
                                    // if logged in user has a display name of "Rider", segue to driver view controller
                                    if user?.displayName == "Rider"{
                                        
                                        self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                        // print("Rider")
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Change to Sign up or Log in mode
    
    @IBAction func bottomTapped(_ sender: Any) {
        
        if signUpMode {
            
            // If in signUpMode, you're tapping "Switch to log in" then do the following:
            topButton.setTitle("Log in", for: .normal)
            bottomButton.setTitle("Switch to sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwtich.isHidden = true
            signUpMode = false
            
        } else {
            
            // If in logInMode, you're tapping "Switch to sign up" then do the following:
            topButton.setTitle("Sign up", for: .normal)
            bottomButton.setTitle("Switch to log in", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwtich.isHidden = false
            signUpMode = true
            
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Display alert method
    
    func displayAlert(title: String, message: String){
        
        // create alert controller with a title and message as its parameters
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // only allow user to tap OK
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // present the controller when displayAlert method is called
        self.present(alertController, animated: true, completion: nil)
        
    }
}

