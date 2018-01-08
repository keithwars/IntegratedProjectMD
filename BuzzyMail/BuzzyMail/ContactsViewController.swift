//
//  ContactsViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    
    let service = OutlookService.shared()
    
    func loadUserData() {
//        self.service.getEvents() {
//            events in
//            if let unwrappedEvents = events {
//                self.dataSource = EventsDataSource(events: unwrappedEvents["value"].arrayValue)
//                self.tableView.dataSource = self.dataSource
//                self.tableView.reloadData()
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

