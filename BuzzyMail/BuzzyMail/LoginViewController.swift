//
//  LoginViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import LocalAuthentication
import UIKit
import WebKit
import SideMenu
import SwiftVideoBackground

class LoginViewController: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all //return the value as per the required orientation
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet var authenticateButton: UIButton!
    
    var context = LAContext()
    let service = OutlookService.shared()
    let videoBackground = VideoBackground()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        videoBackground.play(view: view,
                             videoName: "loginvideo2",
                             videoType: "mp4",
                             isMuted: false,
                             alpha: 0.45,
                             willLoopVideo: true)
        
        doCheck()

        if !service.isLoggedIn {
            continueButton.isHidden = true
        }
        else {
            continueButton.isHidden = false
        }
    }
    
    func doCheck(){
        setLogInState(loggedIn: service.isLoggedIn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLogInState(loggedIn: Bool) {
        if (loggedIn) {
            authenticateButton.setTitle("Log Out", for: UIControlState.normal)
        }
        else {
            authenticateButton.setTitle("Authenticate", for: UIControlState.normal)
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        authenticateTapped()
    }
    @IBAction func loginButtonTapped(sender: AnyObject) {
       
        if (service.isLoggedIn) {
            // Logout
            service.logout()
            setLogInState(loggedIn: false)
            continueButton.isHidden = true
        } else {
            // Login
            service.login(from: self) {
                error in
                if let unwrappedError = error {
                    NSLog("Error logging in: \(unwrappedError)")
                } else {
                    NSLog("Successfully logged in.")
                    self.setLogInState(loggedIn: true)
                    self.continueButton.isHidden = false
                }
            }
        }
    }

    @IBAction func authenticateTapped() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Use Touch ID to continue"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.performSegue(withIdentifier: "continueToApp", sender: self)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}
