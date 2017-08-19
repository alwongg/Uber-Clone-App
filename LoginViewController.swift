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
    
    @IBAction func topTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert(title: "Missing Information", message: "You must provide both an email and a password")
            
        } else {
            
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    
                    
                    if signUpMode {
                        
                        // Sign up
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                                
                                
                                
                                
                            } else {
                                //user successfully signed up
                                
                                if self.riderDriverSwtich.isOn{
                                    // DRIVER
                                    
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Driver"
                                    request?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    print("Driver signed up")
                                    
                                } else {
                                    // RIDER
                                    
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Rider"
                                    request?.commitChanges(completion: nil)
                                    
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    
                                    print("Rider signed up")
                                }
                            }
                        })
                        
                        
                        
                        
                    } else {
                        
                        // Log in
                        
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                            } else {
                                
                                if user?.displayName == "Driver"{
                                    //driver
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    print("Driver")
                                    
                                    
                                    
                                } else {
                                    //rider
                                    
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    
                                    
                                }
                                
                            }
                        })
                        
                        
                    }
                    
                    
                    
                }
                
                
            }
            
           
            
            
            
        }
        
        
    }
    
    // Display errors!
    
    func displayAlert(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        
        if signUpMode {
            
            topButton.setTitle("Log in", for: .normal)
            bottomButton.setTitle("Switch to sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwtich.isHidden = true
            signUpMode = false
            
        } else {
            
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
    
    
}

