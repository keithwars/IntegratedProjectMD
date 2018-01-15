//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SideMenu

class MailViewController: UIViewController/*, UITableViewDataSource, UITableViewDelegate*/ {

    let service = OutlookService.shared()

    var deletePlanetIndexPath: NSIndexPath? = nil

    var messagesList:[Message]?

    let customSideMenuManager = SideMenuManager()

    var currentMailFolder: MailFolder?

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

        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.loadUserEmails()
            //self.loadUserEmailsFolder(mailFolderId: "AQMkADViYgA5NTc1Ni0wODFjLTRlODktYmY0Mi0yNDk0ZTk1ZGIxYTMALgAAA_mdMlZTZwFJiPpRhzdkNwsBABK9rA8i5f5PgECmCrXNdSEAAAIBCQAAAA==")
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
