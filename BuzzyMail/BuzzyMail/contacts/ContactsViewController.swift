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
    
    private let refreshControl = UIRefreshControl()
    let dispatchGroup = DispatchGroup()
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedTitle = NSAttributedString(string: "Refreshing your contacts ...", attributes: attributes)
        
        refreshControl.addTarget(self, action: #selector(refreshContactData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = attributedTitle

        
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
    
    @objc func refreshContactData(_ sender: Any) {
        self.dispatchGroup.enter()
        loadUserData()
        self.dispatchGroup.leave()
        self.dispatchGroup.notify(queue: .main) {
            self.refreshControl.endRefreshing()
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

