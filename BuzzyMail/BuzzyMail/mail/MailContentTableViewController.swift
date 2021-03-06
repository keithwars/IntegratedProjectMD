//
//  MailContentTableViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 7/12/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class MailContentTableViewController: UITableViewController {

    var email:Message?
    
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var ccTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet var richTextEditor: RichTextEditorEditable!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let unwrappedEmail = email {
            richTextEditor.text = unwrappedEmail.body!.content
            subjectTextField.text = unwrappedEmail.subject
            
            for emailAddress in unwrappedEmail.toRecipients! {
                if (toTextField.text != "") {
                    toTextField.text?.append(", ")
                }
                toTextField.text?.append(contentsOf: emailAddress.emailAddress.address)
            }
            
            for emailAddress in unwrappedEmail.ccRecipients! {
                if (ccTextField.text != "") {
                    ccTextField.text?.append(", ")
                }
                ccTextField.text?.append(contentsOf: emailAddress.emailAddress.address)
            }
            
        }

    }
    
}
