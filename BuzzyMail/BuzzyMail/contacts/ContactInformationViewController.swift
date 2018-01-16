//
//  ContactInformationViewController.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 14/01/2018.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit

class ContactInformationViewController: UIViewController {
    
    let service = OutlookService.shared()
    
    var contact:Contact?
    
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circle.layer.cornerRadius = 50
        circle.clipsToBounds = true

        initialsLabel.text = firstLetter(a: (contact?.givenName)!) + firstLetter(a: (contact?.surname)!)
        
        print(contact)
        fullnameLabel.text = contact?.displayName
        emailLabel.text = contact!.emailAddresses![0].address
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.2
        print("email" + emailLabel.text!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
