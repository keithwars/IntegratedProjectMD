//
//  ContactsAddContactViewController.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 14/01/2018.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import UIKit
import Foundation

class ContactsAddContactViewController: UITableViewController, UITextFieldDelegate {
    
    let service = OutlookService.shared()
    
    @IBOutlet weak var textfieldFirstName: UITextField!
    @IBOutlet weak var textfieldLastName: UITextField!
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var textfieldTelephoneNumber: UITextField!
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        textfieldFirstName.inputAccessoryView = toolbar
        textfieldLastName.inputAccessoryView = toolbar
        textfieldEmail.inputAccessoryView = toolbar
        textfieldTelephoneNumber.inputAccessoryView = toolbar
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
    
        let contactToAdd = Contact(
            GivenName: textfieldFirstName.text!,
            SurName: textfieldLastName.text!,
            DisplayName: textfieldFirstName.text! + " " + textfieldLastName.text!,
            EmailAddresses: [EmailAddress(name: textfieldFirstName.text! + " " + textfieldLastName.text!, address: textfieldEmail.text!)],
            BusinessPhones: [textfieldTelephoneNumber.text!]
        )
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // encode, convert to a String, and print it
        
        if let jsonData = try? jsonEncoder.encode(contactToAdd),
            let jsonString = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any] {
            print(jsonString)
            
            self.service.postContact(json: jsonString) {_ in
                
            }
            
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    struct Contact : Codable {
        var GivenName: String
        var SurName: String
        var DisplayName: String
        var EmailAddresses: [EmailAddress]
        var BusinessPhones: [String]?
    }
    
}
