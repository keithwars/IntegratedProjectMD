//
//  EventCell.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 24/11/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Event {
    let subject: String
    let start: String
    let end: String
}

class EventCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    var subject: String? {
        didSet {
            subjectLabel.text = subject
        }
    }
    
    var start: String? {
        didSet {
            startLabel.text = start
        }
    }
    
    var end: String? {
        didSet {
            endLabel.text = end
        }
    }
}

class EventsDataSource: NSObject {
    let events: [Event]
    
    init(events: [JSON]?) {
        var evtArray = [Event]()
        
        if let unwrappedEvents = events {
            for (event) in unwrappedEvents {
                let newEvent = Event(
                    subject: event["subject"].stringValue,
                    start: Formatter.dateTimeTimeZoneToString(date: event["start"]),
                    end: Formatter.dateTimeTimeZoneToString(date: event["end"]))
                
                evtArray.append(newEvent)
            }
        }
        
        self.events = evtArray
    }
}

extension EventsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("\(events.count)")
        NSLog(events[0].subject)
        NSLog(events[1].subject)
        NSLog(events[2].subject)
        NSLog(events[0].start)
        NSLog(events[1].start)
        NSLog(events[2].start)
        NSLog(events[0].end)
        NSLog(events[1].end)
        NSLog(events[2].end)

        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let event = events[indexPath.row]
        cell.subject = event.subject
        cell.start = event.start
        cell.end = event.end
        return cell
    }
}
