//
//  EventCell.swift
//  BuzzyMail
//
//  Created by Lennart Schelfhout on 24/11/2017.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import UIKit
import SwiftyJSON

let currentDate = Date()

struct Event {
    let subject: String?
    let start: String?
    let end: String?
    let startTime: String?
}

class EventCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
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
    
    var startTime: String? {
        didSet {
            startTimeLabel.text = startTime
        }
    }
}

class EventsDataSource: NSObject {
    let events: [Event]
    
    init(events: [JSON]?) {
        var evtArray = [Event]()
        
        if let unwrappedEvents = events {
            for (event) in unwrappedEvents {
                //print("formatted:" + Formatter.deduceTime(start: currentDate))
                
                let newEvent = Event(
                    subject: event["subject"].stringValue,
                    start: Formatter.dateTimeTimeZoneToString(date: event["start"]),
                    end: Formatter.dateTimeToTime(date: event["end"]),
                    startTime: Formatter.timeToHourAndMin(date: event["start"]));
                
                evtArray.append(newEvent)
                
            }
        }
        
        self.events = evtArray
    }
}

extension EventsDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("\(events.count)")

        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let event = events[indexPath.row]
        
        cell.subject = event.subject
        cell.start = event.start
        cell.end = "Ends at: \(event.end!)"
        cell.startTime = event.startTime
        
        return cell
        
    }
}
