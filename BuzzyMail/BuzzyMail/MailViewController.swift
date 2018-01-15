//
//  FirstViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController{

    let service = OutlookService.shared()
    private let refreshControl = UIRefreshControl()
    
    var deletePlanetIndexPath: NSIndexPath? = nil
    var messagesList:[Message]?
    var dataSource: MessagesDataSource?
    
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
        
        if segue.identifier == "showMailContent" {
            if let destination = segue.destination as? MailContentViewController {
                destination.email = messagesList![rowint]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                self.refreshControl.endRefreshing()
                //self.activityIndicatorView.stopAnimating()
            }
        }
    }
}

