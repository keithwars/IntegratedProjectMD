//
//  SecondViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource:EventsDataSource?
    
    let service = OutlookService.shared()
    var eventsList: [Event]?
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
                
                self.service.getEvents() {
                    events in
                    if let unwrappedEvents = events {
                        self.dataSource = EventsDataSource(events: unwrappedEvents["value"].arrayValue)
                        self.tableView.dataSource = self.dataSource
                        self.tableView.reloadData()
                    }
                }
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
