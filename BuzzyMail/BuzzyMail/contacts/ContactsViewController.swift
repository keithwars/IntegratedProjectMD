//
//  ContactsViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate {
    
    let service = OutlookService.shared()
    
    var dataSource: ContactsDataSource?
    var contactsList: [Contact]?
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.estimatedRowHeight = 90;
        
        loadUserData()
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactInformation" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])
            
            contactsList = dataSource?.getContactsArray()
            print(contactsList![rowint].emailAddresses![0])

            if let destination = segue.destination as? ContactInformationViewController {
                destination.contact = contactsList![rowint] as Contact
            }
        }
    }
    
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
}

