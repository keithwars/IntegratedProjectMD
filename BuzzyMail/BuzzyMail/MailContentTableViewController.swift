//
//  MailContentTableViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 7/12/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup
import WebKit

class MailContentTableViewController: UITableViewController {
    @IBOutlet weak var bodyTextView: UITextView!
    

    @IBOutlet var richTextEditor: RichTextEditor!
    
    var email:Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bodyTextView.text = email?.bodyContent
        
        do{
            let html = email?.bodyContent
            let doc: Document = try SwiftSoup.parseBodyFragment(html!)
            //bodyTextView.text = try doc.text()
            richTextEditor.text = "<html><b>EEEEEE</b></html>"
        
            //richTextEditor.placeholder = "eee"
        }catch Exception.Error(let type, let message){
            print(message)
        }catch{
            print("error")
        }
    

    }
}
