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

class ContactCell: UITableViewCell {
    @IBOutlet weak var givenNameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    
    var initials: String? {
        didSet {
           initialsLabel.text = initials
        }
    }
    
    var givenName: String? {
        didSet {
            givenNameLabel.text = givenName
        }
    }
}

class ContactsDataSource: NSObject {
    var contacts: [Contact]
    let service = OutlookService.shared()
    
    init(contacts: [JSON]?) {
        var contactsArray = [Contact]()
        var emailAddressesList = [EmailAddress]()
        
        if let unwrappedContacts = contacts {
            for (contact) in unwrappedContacts {
                //print("formatted:" + Formatter.deduceTime(start: currentDate))
                
                for i in contact["emailAddresses"].arrayValue {
                   emailAddressesList.append(EmailAddress(name: i["name"].stringValue, address: i["address"].stringValue))
                }
                
                let newContact = Contact(
                    id: contact["id"].stringValue,
                    displayName: contact["displayName"].stringValue,
                    givenName: contact["givenName"].stringValue,
                    surname: contact["surname"].stringValue,
                    emailAddresses: emailAddressesList
                )
                
                contactsArray.append(newContact)
                emailAddressesList.removeAll()
            }
        }
        
        self.contacts = contactsArray
    }
}

extension ContactsDataSource: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("total of contacts:" +  "\(contacts.count)")
        
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactCell.self)) as! ContactCell
        let contact = contacts[indexPath.row]
        
        //cell.surname = contact.surname
        cell.givenName = contact.displayName
        cell.initials = firstLetter(a: (contact.displayName)!) + firstLetter(a: (contact.surname)!)
        
        return cell
        
    }
    
    func getContactsArray() -> [Contact] {
        return contacts
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print(action)
            }
            alertController.addAction(cancelAction)

            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                let rowint = Int(indexPath[1])

                let contactToDelete = self.contacts[rowint].id!
                //confirmDelete(event: eventToDelete)
                // delete from events
                self.contacts.remove(at: indexPath.row)

                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.service.deleteContact(id: contactToDelete) {_ in

                }

                tableView.reloadData()
            }

            alertController.addAction(destroyAction)

            let vc = getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)

            vc?.present(alertController, animated: true) {
                print("Run ik hier wel?")
            }

        } else if editingStyle == .insert {

        }
    }
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
}

func firstLetter(a: String) -> String {
    return String(a[a.startIndex])
}
