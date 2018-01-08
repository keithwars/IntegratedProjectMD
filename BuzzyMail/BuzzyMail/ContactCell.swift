//
//  ContactCell.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 08/01/2018.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation

struct Contact {
    let id: String?
    let displayName: String?
    let givenName: String?
    let surname: String?
    let emailAddresses: [EmailAddress]?
}

class ContactCell: UITableViewCell {
    
    class EventCell: UITableViewCell {
        @IBOutlet weak var surnameLabel: UILabel!
        @IBOutlet weak var givenNameLabel: UILabel!
        
        var surname: String? {
            didSet {
                surnameLabel.text = surname
            }
        }
        
        var givenName: String? {
            didSet {
                givenNameLabel.text = givenName
            }
        }
        
    }
}

class ContactsDataSource: NSObject {
    var contacts: [Contact]
    
    init(contacts: [JSON]?) {
        var contactsArray = [Contact]()
        
        if let unwrappedContacts = contacts {
            for (contact) in unwrappedContacts {
                //print("formatted:" + Formatter.deduceTime(start: currentDate))
                
                let newContact = Contact(
                    id: contact["id"].stringValue,
                    displayName: contact["displayName"].stringValue,
                    givenName: contact["givenName"].stringValue,
                    surname: contact["surname"].stringValue,
                    emailAddresses: [EmailAddress(name: contact["emailAddress"]["name"].stringValue, address: contact["emailAddress"]["address"].stringValue)]
                )
                
                contactsArray.append(newContact)
                
            }
        }
        
        self.contacts = contactsArray
    }
}
