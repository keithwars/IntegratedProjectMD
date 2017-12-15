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

    @IBOutlet var richTextEditor: RichTextEditorEditable!
    
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var ccTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    
    var email:Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let unwrappedEmail = email {
            richTextEditor.text = unwrappedEmail.body.content
            subjectTextField.text = unwrappedEmail.subject
        }

    }

    
}
