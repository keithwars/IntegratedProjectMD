//
//  SecondViewController.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 24/11/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    
    let service = OutlookService.shared()
    
    var dataSource:EventsDataSource?
    var eventsList: [CalendarEvent]?
    
    var selectedUser: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelToCalendar(segue: UIStoryboardSegue) {
        
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
        tableView.estimatedRowHeight = 90;
        
        loadUserData()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalendarEvent" {
            let row = self.tableView.indexPathForSelectedRow
            let rowint = Int(row![1])
            eventsList = dataSource?.getEventsArray()
        
            if let destination = segue.destination as? CalendarContentViewController {
                destination.event = eventsList![rowint] as CalendarEvent
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserData() {
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
