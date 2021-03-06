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
    @IBOutlet weak var sendEmailLabel: UILabel!
    @IBOutlet weak var planEventLabel: UILabel!
    
    @IBAction func unwindToContactInformation(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circle.layer.cornerRadius = 50
        circle.clipsToBounds = true

        initialsLabel.text = firstLetter(a: (contact?.givenName)!) + firstLetter(a: (contact?.surname)!)
        
        fullnameLabel.text = contact?.displayName
        emailLabel.text = contact!.emailAddresses![0].address
        print("emaillabelteksts: " + emailLabel.text!)
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.2
        
        sendEmailLabel.text = contact!.emailAddresses![0].address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "planEventWithUser" {
            if let navCT = segue.destination as? UINavigationController {
                if let destination = navCT.topViewController as? CalendarAddEventViewController {
                    destination.selectedUser = emailLabel.text
                    print("hahah" + emailLabel.text!)
                }
            }
        }
        else if segue.identifier == "sendEmailToContact" {
            if let destination = segue.destination as? ReplyMailViewController {
                destination.email = sendEmailLabel.text
                print("heheheh" + destination.email!)
            }
        }
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
