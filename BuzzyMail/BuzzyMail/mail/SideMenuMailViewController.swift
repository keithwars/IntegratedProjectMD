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
    
    let service = OutlookService.shared()
    
    var dataSource: MailFoldersDataSource?
    var mailFoldersList: [MailFolder]?
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "closeSideMenu" {
            let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
            if let selected = selectedIndex {
                mailFoldersList = dataSource?.getMailFoldersArray()
                if let destination = segue.destination as? MailViewController {
                    currentMailFolder = mailFoldersList![selected.row]
                }
            }
        } else if segue.identifier == "logout" {
            service.logout()
        }
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
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
    
        let ct = self.view.window?.rootViewController
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        service.logout()
        ct?.viewDidLoad()
    }
    
}
