//
//  LoginViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import WebKit
import SwiftVideoBackground

class LoginViewController: UIViewController {
    private let videoBackground = VideoBackground()

    
    @IBOutlet var logInButton: UIButton!
    
    let service = OutlookService.shared()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoBackground.play(view: view,
                             videoName: "loginvideo",
                             videoType: "mp4",
                             isMuted: false,
                             alpha: 0.25,
                             willLoopVideo: true)
        
        // Do any additional setup after loading the view, typically from a nib.
        setLogInState(loggedIn: service.isLoggedIn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLogInState(loggedIn: Bool) {
        if (loggedIn) {
            logInButton.setTitle("Log Out", for: UIControlState.normal)
        }
        else {
            logInButton.setTitle("Authenticate", for: UIControlState.normal)
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        if (service.isLoggedIn) {
            // Logout
            service.logout()
            setLogInState(loggedIn: false)
        } else {
            // Login
            service.login(from: self) {
                error in
                if let unwrappedError = error {
                    NSLog("Error logging in: \(unwrappedError)")
                } else {
                    NSLog("Successfully logged in.")
                    self.setLogInState(loggedIn: true)
                }
            }
        }
    }

}
