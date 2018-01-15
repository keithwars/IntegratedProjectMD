//
//  ContactsViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: ContactsDataSource?
    
    let service = OutlookService.shared()
    var contactsList: [Contact]?
    
    func loadUserData() {
        self.service.getContacts() {
            contacts in
            if let unwrappedContacts = contacts {
                self.dataSource = ContactsDataSource(contacts: unwrappedContacts["value"].arrayValue)
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactInformation" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])
            
            contactsList = dataSource?.getContactsArray()
            
            if let destination = segue.destination as? ContactInformationViewController {
                destination.contact = contactsList![rowint]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
        
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        tableView.rowHeight = 90;
        // Do any additional setup after loading the view, typically from a nib.
        tableView.estimatedRowHeight = 90;
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        if (service.isLoggedIn) {
            loadUserData()
            tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

