//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SideMenu

class MailViewController: UIViewController{

    let service = OutlookService.shared()
    let customSideMenuManager = SideMenuManager()
    private let refreshControl = UIRefreshControl()
    
    var messagesList:[Message]?
    var dataSource: MessagesDataSource?
    var currentMailFolder: MailFolder?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80;
        loadUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Configure Side Menu
        SideMenuManager.default.menuWidth = max(round(min((UIScreen.main.bounds.width), (UIScreen.main.bounds.height)) * 0.80), 240)
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear

        if let currentMailFolder = currentMailFolder {
            self.loadUserEmailsFolder(mailFolderId: currentMailFolder.id)
        }
        else {
            loadUserData()
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedTitle = NSAttributedString(string: "Refreshing your e-mails ...", attributes: attributes)
        
        refreshControl.addTarget(self, action: #selector(refreshEmailData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = attributedTitle

        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMailContent" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])
            messagesList = dataSource?.getMessagesArray()
            
            if let destination = segue.destination as? MailContentViewController {
                destination.email = messagesList![rowint]
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeSideMenu(_ segue: UIStoryboardSegue) {
        if let currentMailFolder = currentMailFolder {
            NSLog("Loading New Mail Folder: " + currentMailFolder.displayName)
            self.loadUserEmailsFolder(mailFolderId: currentMailFolder.id)
        }
        self.title = currentMailFolder!.displayName
    }
    
    
    @IBAction func cancelToMailContentViewController(_ segue: UIStoryboardSegue) { }
    
    @objc func refreshEmailData(_ sender: Any) {
        if let currentMailFolder = currentMailFolder {
            self.loadUserEmailsFolder(mailFolderId: currentMailFolder.id)
        }
        else {
            loadUserData()
        }
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }

    func loadUserData() {
        loadInboxMailFolderName()
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                self.loadUserEmails()
                self.refreshControl.endRefreshing()
                //self.activityIndicatorView.stopAnimating()
            }
        }
    }

    func loadUserEmails() {
        loadInboxMailFolderName()
        self.service.getInboxMessages() {
            messages in
            if let unwrappedMessages = messages {
                self.dataSource = MessagesDataSource(messages: unwrappedMessages["value"].arrayValue)
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
            }
        }
    }

    func loadUserEmailsFolder(mailFolderId: String) {
        self.service.getMailFolderMessages(mailFolderId: mailFolderId) {
            messages in
            if let unwrappedMessages = messages {
                self.dataSource = MessagesDataSource(messages: unwrappedMessages["value"].arrayValue)
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }

    func loadInboxMailFolderName() {
        self.service.getMailFolderByName(mailFolderName: "inbox") {
            mailFolder in
            if let unwrappedMailFolder = mailFolder {
                self.title = unwrappedMailFolder["displayName"].stringValue
            }
        }
    }
}
