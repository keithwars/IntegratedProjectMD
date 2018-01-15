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
    private let refreshControl = UIRefreshControl()
    
    var deletePlanetIndexPath: NSIndexPath? = nil
    var messagesList:[Message]?
    var dataSource: MessagesDataSource?
    var currentMailFolder: MailFolder?
    let customSideMenuManager = SideMenuManager()

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
        

        /*
        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            if editingStyle == .delete {
                deleteEmailIndexPath = indexPath
                let rowsToDelete = messagesList![rowint]
                confirmDelete(emailToDelete)
            }
        }


        func confirmDelete(Email: String) {
            let alert = UIAlertController(title: "Delete Email", message: "Are you sure you want to permanently delete \(Email)?", preferredStyle: .actionSheet)

            let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: )
            let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:)

            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)

            // Support display in iPad
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)

            self.presentViewController(alert, animated: true, completion: nil)
        }

 */

        if segue.identifier == "showMailContent" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])

            messagesList = dataSource?.getMessagesArray()

            if let destination = segue.destination as? MailContentViewController {
                destination.email = messagesList![rowint]
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        SideMenuManager.default.menuWidth = max(round(min((UIScreen.main.bounds.width), (UIScreen.main.bounds.height)) * 0.80), 240)
        //SideMenuManager.default.menuFadeStatusBar = true
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear
        //SideMenuManager.default.menuAnimationBackgroundColor = UIColor(rgb: 0x0096FF)
        super.viewWillAppear(animated)

        loadUserData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
    
    @objc func refreshEmailData(_ sender: Any) {
        // Fetch Email Data
        loadUserData()
    }

    @IBAction func closeSideMenu(_ segue: UIStoryboardSegue) {
        if let currentMailFolder = currentMailFolder {
            NSLog("Loading New Mail Folder: " + currentMailFolder.displayName)
            self.loadUserEmailsFolder(mailFolderId: currentMailFolder.id)
        }
        self.title = currentMailFolder!.displayName
    }


    func loadUserData() {
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
    
    @IBAction func cancelToMailContentViewController(_ segue: UIStoryboardSegue) {
        
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
