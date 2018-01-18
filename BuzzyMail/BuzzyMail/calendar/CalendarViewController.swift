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
    
    private let refreshControl = UIRefreshControl()
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelToCalendar(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedTitle = NSAttributedString(string: "Refreshing your contacts ...", attributes: attributes)
        
        refreshControl.addTarget(self, action: #selector(refreshCalendarData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = attributedTitle

        
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
    
    @objc func refreshCalendarData(_ sender: Any) {
        self.dispatchGroup.enter()
        loadUserData()
        self.dispatchGroup.leave()
        self.dispatchGroup.notify(queue: .main) {
            self.refreshControl.endRefreshing()
        }
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
