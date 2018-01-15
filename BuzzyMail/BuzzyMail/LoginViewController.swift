//
//  LoginViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import WebKit
import SideMenu
import SwiftVideoBackground

class LoginViewController: UIViewController {
    
    let service = OutlookService.shared()
    private let videoBackground = VideoBackground()

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet var authenticateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        videoBackground.play(view: view,
                             videoName: "loginvideo",
                             videoType: "mp4",
                             isMuted: false,
                             alpha: 0.25,
                             willLoopVideo: true)
        
        setLogInState(loggedIn: service.isLoggedIn)
        if !service.isLoggedIn {
            continueButton.isHidden = true
        }
        else {
            continueButton.isHidden = false
        }
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

}
