//
//  SideMenuMailViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 8/01/18.
//  Copyright © 2018 Jérémy Keusters. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class SideMenuMailViewController: UITableViewController {
    
    var dataSource: MailFoldersDataSource?
    
    override func viewDidLoad() {
        loadMailFolders()
        setUserGivenName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMailFolders() {
        service.getMailFolders() {
            mailFolders in
            if let unwrappedMailFolders = mailFolders {
                self.dataSource = MailFoldersDataSource(mailFolders: unwrappedMailFolders["value"].arrayValue)
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
            }
        }
    }
    
    func setUserGivenName () {
        self.title = "Hi " + service.userGivenName
    }
    
}
