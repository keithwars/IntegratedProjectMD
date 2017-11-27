//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {

    let service = OutlookService.shared()
    
    var messagesList:[Message]?
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: MessagesDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80;
        
        // Do any additional setup after loading the view, typically from a nib.
        if(service.isLoggedIn) {
            loadUserData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let row = self.tableView.indexPathForSelectedRow
        let rowint = Int(row![1])
        
        messagesList = dataSource?.getMessagesArray()
        
        NSLog(messagesList![rowint].subject)
                
        if segue.identifier == "showMailContent" {
            if let destination = segue.destination as? MailContentViewController {
                destination.email = messagesList![rowint]
            }
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserData() {
        NSLog("Test")
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
                
                self.service.getInboxMessages() {
                    messages in
                    if let unwrappedMessages = messages {
                        self.dataSource = MessagesDataSource(messages: unwrappedMessages["value"].arrayValue)
                        self.tableView.dataSource = self.dataSource
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    

}

