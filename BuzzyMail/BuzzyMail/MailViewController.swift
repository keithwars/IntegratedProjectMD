//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController/*, UITableViewDataSource, UITableViewDelegate*/ {

    let service = OutlookService.shared()

    var deletePlanetIndexPath: NSIndexPath? = nil

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

        NSLog(messagesList![rowint].subject!)

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
            if let destination = segue.destination as? MailContentViewController {
                destination.email = messagesList![rowint]
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUserData() {
        service.getUserEmail() {
            email in
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
